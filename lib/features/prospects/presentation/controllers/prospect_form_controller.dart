import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../settings/data/models/prospect_form_option.dart';
import '../../../settings/data/models/sales_stage.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_requests.dart';
import '../../domain/prospects_repository.dart';

/// Create / edit a prospect.
///
/// On creation the initial stage is chosen here; afterwards the stage only
/// changes through stage transitions (so history is recorded).
class ProspectFormController extends GetxController {
  ProspectFormController({
    required ProspectsRepository repository,
    required this.lookups,
    this.initial,
  }) : _repository = repository;

  final ProspectsRepository _repository;
  final LookupService lookups;
  final Prospect? initial;

  bool get isEdit => initial != null;

  final formKey = GlobalKey<FormState>();
  late final companyName = TextEditingController(text: initial?.companyName);
  late final contactName = TextEditingController(text: initial?.contactName);
  late final phone = TextEditingController(text: initial?.phone);
  late final email = TextEditingController(text: initial?.email);
  late final address = TextEditingController(text: initial?.address);
  late final city = TextEditingController(text: initial?.city);
  late final notes = TextEditingController(text: initial?.notes);

  // 4 Configurable Lists: Source, Previous software, Business activity, Profession
  late final source = Rxn<String>(
    (initial?.source ?? '').trim().isEmpty ? null : initial!.source,
  );
  late final sourceDetails = TextEditingController(
    text: initial?.sourceDetails ?? initial?.sourceOther,
  );

  late final businessActivity = Rxn<String>(
    (initial?.businessActivity ?? '').trim().isEmpty
        ? null
        : initial!.businessActivity,
  );
  late final businessActivityDetails = TextEditingController(
    text: initial?.businessActivityDetails,
  );

  late final previousSoftware = Rxn<String>(
    (initial?.previousSoftware ?? '').trim().isEmpty
        ? null
        : initial!.previousSoftware,
  );
  late final previousSoftwareDetails = TextEditingController(
    text: initial?.previousSoftwareDetails,
  );

  late final profession = Rxn<String>(
    (initial?.profession ?? '').trim().isEmpty ? null : initial!.profession,
  );
  late final professionDetails = TextEditingController(
    text: initial?.professionDetails,
  );

  final selectedStage = Rxn<SalesStage>();
  final selectedProductIds = <int>{}.obs;

  final lookupState = LoadState();
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  /// Field errors returned by the server (422), keyed by API field name.
  final serverErrors = <String, String>{}.obs;

  /// API fields this form displays next to an input. Server errors on any
  /// other field are added to [errorMessage] so they are never hidden.
  static const displayedFields = {
    'name',
    'contact_person',
    'phone',
    'email',
    'address',
    'city',
    'business_activity',
    'business_activity_details',
    'profession',
    'profession_details',
    'source',
    'source_details',
    'previous_software',
    'previous_software_details',
    'notes',
    'sales_stage_id',
    'product_ids',
  };

  /// Set after the first submit attempt so non-text fields show errors.
  final showValidation = false.obs;

  bool get isSourceDetailsRequired {
    final opt = lookups.findOption(ProspectFormOption.typeSource, source.value);
    return opt?.requiresDetails ?? false;
  }

  bool get isBusinessActivityDetailsRequired {
    final opt = lookups.findOption(
      ProspectFormOption.typeBusinessActivity,
      businessActivity.value,
    );
    return opt?.requiresDetails ?? false;
  }

  bool get isPreviousSoftwareDetailsRequired {
    final opt = lookups.findOption(
      ProspectFormOption.typePreviousSoftware,
      previousSoftware.value,
    );
    return opt?.requiresDetails ?? false;
  }

  bool get isProfessionDetailsRequired {
    final opt = lookups.findOption(
      ProspectFormOption.typeProfession,
      profession.value,
    );
    return opt?.requiresDetails ?? false;
  }

  @override
  void onInit() {
    super.onInit();
    selectedProductIds.addAll(initial?.products.map((p) => p.id) ?? const []);
    loadLookups();
  }

  Future<void> loadLookups() async {
    await lookupState.run(lookups.ensureLoaded);
    if (!isEdit && selectedStage.value == null) {
      // Default to the first active open stage of the pipeline.
      selectedStage.value =
          lookups.activeStages.firstWhereOrNull((s) => s.isOpen) ??
          lookups.activeStages.firstOrNull;
    }
  }

  void toggleProduct(int productId, bool selected) {
    if (selected) {
      selectedProductIds.add(productId);
    } else {
      selectedProductIds.remove(productId);
    }
    serverErrors.remove('product_ids');
  }

  void selectStage(SalesStage? stage) {
    selectedStage.value = stage;
    serverErrors.remove('sales_stage_id');
  }

  void selectSource(String? value) {
    source.value = value;
    serverErrors.remove('source');
    serverErrors.remove('source_details');
  }

  void selectBusinessActivity(String? value) {
    businessActivity.value = value;
    serverErrors.remove('business_activity');
    serverErrors.remove('business_activity_details');
  }

  void selectPreviousSoftware(String? value) {
    previousSoftware.value = value;
    serverErrors.remove('previous_software');
    serverErrors.remove('previous_software_details');
  }

  void selectProfession(String? value) {
    profession.value = value;
    serverErrors.remove('profession');
    serverErrors.remove('profession_details');
  }

  Future<ProspectFormOption?> addOption({
    required String type,
    required String name,
    bool requiresDetails = false,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    try {
      final created = await lookups.addProspectFormOption(
        type: type,
        name: trimmed,
        requiresDetails: requiresDetails,
      );
      return created;
    } catch (e) {
      final error = ApiException.from(e);
      AppFeedback.error(error.message);
      return null;
    }
  }

  void clearServerError(String field) => serverErrors.remove(field);

  // --- Field validators (client rules + server message for that field) ---

  String? validateCompanyName(String? v) =>
      serverErrors['name'] ??
      Validators.combine([
        () => Validators.required(v, field: tr.validFieldCompany),
        () => Validators.maxLength(v, 150),
      ]);

  String? validateContactName(String? v) =>
      serverErrors['contact_person'] ?? Validators.maxLength(v, 150);

  String? validatePhone(String? v) =>
      serverErrors['phone'] ??
      Validators.combine([
        () => Validators.phone(v),
        () => Validators.maxLength(v, 30),
      ]);

  String? validateEmail(String? v) =>
      serverErrors['email'] ?? Validators.email(v);

  String? validateAddress(String? v) =>
      serverErrors['address'] ?? Validators.maxLength(v, 255);

  String? validateCity(String? v) =>
      serverErrors['city'] ?? Validators.maxLength(v, 100);

  String? validateSourceDetails(String? v) {
    if (serverErrors['source_details'] != null) {
      return serverErrors['source_details'];
    }
    if (isSourceDetailsRequired && (v == null || v.trim().isEmpty)) {
      return tr.validDetailsRequired;
    }
    return Validators.maxLength(v, 255);
  }

  String? validateBusinessActivityDetails(String? v) {
    if (serverErrors['business_activity_details'] != null) {
      return serverErrors['business_activity_details'];
    }
    if (isBusinessActivityDetailsRequired && (v == null || v.trim().isEmpty)) {
      return tr.validDetailsRequired;
    }
    return Validators.maxLength(v, 255);
  }

  String? validatePreviousSoftwareDetails(String? v) {
    if (serverErrors['previous_software_details'] != null) {
      return serverErrors['previous_software_details'];
    }
    if (isPreviousSoftwareDetailsRequired && (v == null || v.trim().isEmpty)) {
      return tr.validDetailsRequired;
    }
    return Validators.maxLength(v, 255);
  }

  String? validateProfessionDetails(String? v) {
    if (serverErrors['profession_details'] != null) {
      return serverErrors['profession_details'];
    }
    if (isProfessionDetailsRequired && (v == null || v.trim().isEmpty)) {
      return tr.validDetailsRequired;
    }
    return Validators.maxLength(v, 255);
  }

  String? validateNotes(String? v) =>
      serverErrors['notes'] ?? Validators.maxLength(v, 10000);

  String? get stageError {
    if (serverErrors['sales_stage_id'] != null) {
      return serverErrors['sales_stage_id'];
    }
    if (isEdit || !showValidation.value) return null;
    final stage = selectedStage.value;
    if (stage == null) return tr.validInitialStageRequired;
    if (!stage.isActive) return tr.validStageDisabled;
    return null;
  }

  String? get productsError => serverErrors['product_ids'];

  /// Validates all fields without needing the widget tree. Returns the
  /// first error per field.
  Map<String, String> validateAll() {
    final errors = <String, String>{};
    void check(String field, String? error) {
      if (error != null) errors[field] = error;
    }

    check('name', validateCompanyName(companyName.text));
    check('contact_person', validateContactName(contactName.text));
    check('phone', validatePhone(phone.text));
    check('email', validateEmail(email.text));
    check('address', validateAddress(address.text));
    check('city', validateCity(city.text));
    check('source_details', validateSourceDetails(sourceDetails.text));
    check(
      'business_activity_details',
      validateBusinessActivityDetails(businessActivityDetails.text),
    );
    check(
      'previous_software_details',
      validatePreviousSoftwareDetails(previousSoftwareDetails.text),
    );
    check(
      'profession_details',
      validateProfessionDetails(professionDetails.text),
    );
    check('notes', validateNotes(notes.text));
    if (!isEdit) {
      final stage = selectedStage.value;
      if (stage == null) {
        errors['sales_stage_id'] = tr.validInitialStageRequired;
      } else if (!stage.isActive) {
        errors['sales_stage_id'] = tr.validStageDisabled;
      }
    }
    return errors;
  }

  ProspectPayload buildPayload() => ProspectPayload(
    companyName: companyName.text,
    contactName: contactName.text,
    phone: phone.text,
    email: email.text,
    address: address.text,
    city: city.text,
    businessActivity: businessActivity.value,
    businessActivityDetails: businessActivityDetails.text.trim().isEmpty
        ? null
        : businessActivityDetails.text.trim(),
    profession: profession.value,
    professionDetails: professionDetails.text.trim().isEmpty
        ? null
        : professionDetails.text.trim(),
    source: source.value,
    sourceDetails: sourceDetails.text.trim().isEmpty
        ? null
        : sourceDetails.text.trim(),
    previousSoftware: previousSoftware.value,
    previousSoftwareDetails: previousSoftwareDetails.text.trim().isEmpty
        ? null
        : previousSoftwareDetails.text.trim(),
    notes: notes.text,
    salesStageId: isEdit ? null : selectedStage.value?.id,
    productIds: selectedProductIds.toList()..sort(),
  );

  /// Returns the saved prospect, or null if validation / the API failed
  /// (details in [errorMessage] and [serverErrors]).
  Future<Prospect?> submit() async {
    if (isSubmitting.value) return null; // duplicate click protection
    showValidation.value = true;
    serverErrors.clear();
    errorMessage.value = null;

    final widgetValid = formKey.currentState?.validate() ?? true;
    final errors = validateAll();
    if (!widgetValid || errors.isNotEmpty) {
      errorMessage.value = tr.validFixFields;
      return null;
    }

    isSubmitting.value = true;
    try {
      final payload = buildPayload();
      return isEdit
          ? await _repository.updateProspect(initial!.id, payload)
          : await _repository.createProspect(payload);
    } on ValidationException catch (e) {
      _applyServerErrors(e);
      return null;
    } catch (e) {
      errorMessage.value = ApiException.from(e).message;
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _applyServerErrors(ValidationException e) {
    final mapped = <String, String>{};
    e.fieldErrors.forEach((key, messages) {
      if (messages.isEmpty) return;
      // `product_ids.0` → `product_ids`
      final field = key.split('.').first;
      mapped.putIfAbsent(field, () => messages.first);
    });
    serverErrors.assignAll(mapped);
    errorMessage.value = e.describeFor(displayedFields);
    formKey.currentState?.validate();
  }

  @override
  void onClose() {
    for (final c in [
      companyName,
      contactName,
      phone,
      email,
      address,
      city,
      notes,
      sourceDetails,
      businessActivityDetails,
      previousSoftwareDetails,
      professionDetails,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
