import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/workflow_lookup_service.dart';
import '../../../../core/models/named_ref.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/state/action_result.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/file_access.dart';
import '../../../workflow_settings/data/models/config_models.dart';
import '../../data/models/intervention.dart';
import '../../domain/interventions_repository.dart';

/// Triage list: filters by configured status / priority / type, sorted by
/// priority (the order of priorities is configuration, not code).
class InterventionsController extends GetxController {
  InterventionsController({
    required InterventionsRepository repository,
    required this.workflow,
  }) : _repository = repository;

  final InterventionsRepository _repository;
  final WorkflowLookupService workflow;

  final page = Rx<Paginated<Intervention>>(const Paginated.empty());
  final state = LoadState();
  final filter = const InterventionFilter(open: true).obs;

  /// Items of the current page, most urgent first. Unprioritised items come
  /// last; ties are broken by newest first.
  ///
  /// A clicked column ([sortKey]) overrides the default urgency order; the
  /// sort applies to the loaded page only.
  final sortKey = RxnString();
  final ascending = true.obs;

  void sortBy(String key) {
    ascending.value = sortKey.value == key ? !ascending.value : true;
    sortKey.value = key;
  }

  List<Intervention> get sorted {
    final list = page.value.items.toList();
    int rank(Intervention i) => i.priority?.sortOrder ?? 1 << 30;
    final key = sortKey.value;
    if (key == null) {
      list.sort((a, b) {
        final byPriority = rank(a).compareTo(rank(b));
        return byPriority != 0 ? byPriority : b.id.compareTo(a.id);
      });
      return list;
    }
    Comparable<Object> value(Intervention i) => switch (key) {
      'priority' => rank(i),
      'reference' => i.reference.toLowerCase(),
      'title' => i.title.toLowerCase(),
      'type' => (i.type?.name ?? '').toLowerCase(),
      'status' => (i.status?.name ?? '').toLowerCase(),
      'assigned' => (i.assignedEmployee ?? '').toLowerCase(),
      _ => i.id,
    };
    final dir = ascending.value ? 1 : -1;
    list.sort((a, b) => dir * value(a).compareTo(value(b)));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    page.value = await _repository.getInterventions(filter.value);
  });

  Future<void> setFilter(InterventionFilter value) {
    filter.value = value.copyWith(page: 1);
    return load();
  }

  Future<void> goToPage(int value) {
    filter.value = filter.value.copyWith(page: value);
    return load();
  }
}

/// One intervention: status workflow, triage fields, conversation (internal
/// notes vs customer-visible replies) and release notes.
class InterventionDetailController extends GetxController {
  InterventionDetailController({
    required this.interventionId,
    required InterventionsRepository repository,
    required this.workflow,
  }) : _repository = repository;

  final int interventionId;
  final InterventionsRepository _repository;
  final WorkflowLookupService workflow;

  final intervention = Rxn<Intervention>();
  final transitions = <AllowedTransition>[].obs;
  final state = LoadState();
  final isBusy = false.obs;

  /// Composer. Defaults to the safe choice: an internal note.
  final message = TextEditingController();
  final customerVisible = false.obs;

  /// Label the files of the next customer reply as a private hotfix patch.
  final isHotfix = false.obs;

  /// Files waiting to be sent with the next reply (max [maxFiles]).
  final pendingFiles = <PickedFile>[].obs;
  static const maxFiles = 5;

  /// Replies are possible only while the intervention is open (`can_reply`).
  bool get canReply => intervention.value?.canReply ?? true;

  /// Employees reopen closed interventions from the options menu.
  bool get canReopen => intervention.value?.canReply == false;

  /// Adds [picked] to the composer, skipping duplicates and anything beyond
  /// [maxFiles]. Returns how many files were left out.
  int addFiles(List<PickedFile> picked) {
    var skipped = 0;
    for (final file in picked) {
      if (pendingFiles.any((f) => f.path == file.path)) continue;
      if (pendingFiles.length >= maxFiles) {
        skipped++;
        continue;
      }
      pendingFiles.add(file);
    }
    return skipped;
  }

  void removeFile(PickedFile file) =>
      pendingFiles.removeWhere((f) => f.path == file.path);

  /// Opens the native dialog and queues the chosen files. Returns the number
  /// of files that did not fit in the limit.
  Future<int> pickFiles() async {
    final picked = await FileAccess.pick(
      extensions: FileAccess.attachmentExtensions,
    );
    return addFiles(picked);
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => state.run(() async {
    intervention.value = await _repository.getIntervention(interventionId);
    await _loadTransitions();
  });

  Future<void> _loadTransitions() async {
    try {
      transitions.assignAll(await _repository.getTransitions(interventionId));
    } catch (_) {
      // The status picker stays empty rather than offering a wrong list.
      transitions.clear();
    }
  }

  /// Statuses the picker offers: only the configured transitions from the
  /// current status, and only active statuses.
  List<InterventionStatus> get allowedStatuses => [
    for (final t in transitions)
      if (workflow.statusById(t.statusId) case final s? when s.isActive) s,
  ];

  bool canTransitionTo(int statusId) =>
      transitions.any((t) => t.statusId == statusId);

  Future<ActionResult<Intervention>> changeStatus(
    int statusId, {
    String? customerMessage,
  }) async {
    if (!canTransitionTo(statusId)) {
      return ActionResult.failure(
        ValidationException(tr.wfTransitionNotAllowed),
      );
    }
    return _run(
      () => _repository.transition(
        interventionId,
        statusId,
        customerMessage: customerMessage,
      ),
    );
  }

  Future<ActionResult<Intervention>> updateTriage({
    int? priorityId,
    bool clearPriority = false,
    String? assignedEmployee,
    bool clearAssignee = false,
    DateTime? scheduledAt,
    bool clearSchedule = false,
  }) => _run(
    () => _repository.updateIntervention(
      interventionId,
      priorityId: priorityId,
      clearPriority: clearPriority,
      assignedEmployee: assignedEmployee,
      clearAssignee: clearAssignee,
      scheduledAt: scheduledAt,
      clearSchedule: clearSchedule,
    ),
  );

  /// Sends the composer text (and attachments) as an internal note or a
  /// customer reply.
  Future<ActionResult<Intervention>> sendMessage() async {
    if (!canReply) {
      return ActionResult.failure(
        ValidationException(tr.ivClosedBanner, errorCode: closedCode),
      );
    }
    final body = message.text.trim();
    if (body.isEmpty && pendingFiles.isEmpty) {
      return ActionResult.failure(ValidationException(tr.wfMessageRequired));
    }
    final files = pendingFiles.toList();
    final result = await _run(
      () => _repository.addMessage(
        interventionId,
        customerVisible: customerVisible.value,
        body: body,
        files: files,
        hotfix: isHotfix.value && files.isNotEmpty,
      ),
    );
    if (result.isSuccess) {
      message.clear();
      pendingFiles.clear();
      isHotfix.value = false;
    }
    return result;
  }

  /// Server error code when the intervention was closed in the meantime.
  static const closedCode = 'INTERVENTION_CLOSED';

  /// Reopens a closed intervention (employees only): replies are enabled
  /// again and the timeline records who did it.
  Future<ActionResult<Intervention>> reopen({String? note}) =>
      _run(() => _repository.reopen(interventionId, note: note));

  /// Saves an attachment to the Downloads folder; resolves with its path.
  Future<ActionResult<String>> saveAttachment(
    InterventionAttachment attachment,
  ) => ActionResult.guard(() async {
    final path = FileAccess.freePath(
      FileAccess.downloadsDirectory(),
      attachment.name,
    );
    await _repository.downloadAttachment(
      interventionId,
      attachment.id,
      path,
    );
    return path;
  });

  /// Downloads a PDF to the temp folder and opens it with the system viewer.
  Future<ActionResult<String>> openAttachment(
    InterventionAttachment attachment,
  ) => ActionResult.guard(() async {
    final path = FileAccess.freePath(
      FileAccess.tempDirectory(),
      attachment.name,
    );
    await _repository.downloadAttachment(interventionId, attachment.id, path);
    await FileAccess.open(path);
    return path;
  });

  final _previews = <int, Future<Uint8List>>{};

  /// Bytes of an image attachment for the thumbnail and full-screen viewer,
  /// fetched once per attachment (a failed fetch is retried next time).
  Future<Uint8List> previewOf(InterventionAttachment attachment) =>
      _previews.putIfAbsent(
        attachment.id,
        () => _repository
            .previewAttachment(interventionId, attachment.id)
            .catchError((Object e) {
              _previews.remove(attachment.id);
              throw e;
            }),
      );

  Future<ActionResult<Intervention>> publish(String resolution) {
    if (resolution.trim().isEmpty) {
      return Future.value(
        ActionResult.failure(ValidationException(tr.wfResolutionRequired)),
      );
    }
    return _run(() => _repository.publish(interventionId, resolution));
  }

  Future<ActionResult<Intervention>> unpublish() =>
      _run(() => _repository.unpublish(interventionId));

  Future<ActionResult<Intervention>> _run(
    Future<Intervention> Function() task,
  ) async {
    if (isBusy.value) {
      return ActionResult.failure(CancelledApiException(tr.errBusy));
    }
    isBusy.value = true;
    try {
      final result = await ActionResult.guard(task);
      if (result.isSuccess) {
        intervention.value = result.value;
        await _loadTransitions();
        return result;
      }
      if (result.error?.errorCode == closedCode) {
        // Closed by someone else meanwhile: refresh so the composer locks,
        // and say so in the user's language.
        try {
          intervention.value = await _repository.getIntervention(
            interventionId,
          );
          await _loadTransitions();
        } catch (_) {
          // The banner will appear on the next refresh.
        }
        return ActionResult.failure(
          ValidationException(tr.ivClosedBanner, errorCode: closedCode),
        );
      }
      return result;
    } finally {
      isBusy.value = false;
    }
  }

  @override
  void onClose() {
    message.dispose();
    super.onClose();
  }
}

/// Creates an employee-originated intervention (fix, release, update ...).
class InterventionFormController extends GetxController {
  InterventionFormController({
    required InterventionsRepository repository,
    required this.workflow,
  }) : _repository = repository {
    final types = workflow.employeeInterventionTypes;
    if (types.isNotEmpty) type.value = types.first;
    final self = workflow.identity.username;
    if (self.isNotEmpty) employee.value = self;
  }

  final InterventionsRepository _repository;
  final WorkflowLookupService workflow;

  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final description = TextEditingController();
  final type = Rxn<InterventionType>();
  final priority = Rxn<InterventionPriority>();
  final productId = RxnInt();
  final employee = RxnString();
  final scheduledAt = Rxn<DateTime>();
  final customers = <NamedRef>[].obs;

  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final serverErrors = <String, String>{}.obs;

  String? validateTitle(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return serverErrors['title'] ?? tr.wfTitleRequired;
    if (t.length > 200) return tr.wfTooLong(200);
    return serverErrors['title'];
  }

  String? validateDescription(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) {
      return serverErrors['description'] ?? tr.wfDescriptionRequired;
    }
    return serverErrors['description'];
  }

  void addCustomer(NamedRef customer) {
    if (!customers.contains(customer)) customers.add(customer);
  }

  void removeCustomer(NamedRef customer) => customers.remove(customer);

  InterventionPayload buildPayload() => InterventionPayload(
    typeId: type.value!.id,
    title: title.text,
    description: description.text,
    priorityId: priority.value?.id,
    productId: productId.value,
    customerIds: customers.map((c) => c.id).toList(),
    assignedEmployee: employee.value,
    scheduledAt: scheduledAt.value,
  );

  Future<Intervention?> submit() async {
    if (isSubmitting.value) return null;
    serverErrors.clear();
    errorMessage.value = null;
    final valid = formKey.currentState?.validate() ?? true;
    if (type.value == null) {
      errorMessage.value = tr.wfSelectType;
      return null;
    }
    if (!valid) return null;
    isSubmitting.value = true;
    try {
      return await _repository.createIntervention(buildPayload());
    } on ValidationException catch (e) {
      e.fieldErrors.forEach((k, m) {
        if (m.isNotEmpty) serverErrors[k.split('.').first] = m.first;
      });
      errorMessage.value = e.describeFor(const {'title', 'description'});
      formKey.currentState?.validate();
      return null;
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    title.dispose();
    description.dispose();
    super.onClose();
  }
}
