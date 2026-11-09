import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/load_state.dart';
import '../../../../core/utils/validators.dart';
import '../../../settings/data/models/sales_stage.dart';
import '../../data/models/prospect.dart';
import '../../data/models/prospect_catalogs.dart';
import '../../data/models/prospect_requests.dart';
import '../../domain/prospects_repository.dart';
import '../../../../app/l10n/l10n.dart';

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

  // Business profile. business activity / previous software are a catalogue
  // code or free text: the field shows the label (or the text), and the
  // matching code is what gets saved.
  late final businessActivity = TextEditingController(
    text: initial?.businessActivity == null
        ? ''
        : ProspectCatalogs.labelOf(
            ProspectCatalogs.businessActivities,
            initial!.businessActivity,
          ),
  );
  late final previousSoftware = TextEditingController(
    text: initial?.previousSoftware == null
        ? ''
        : ProspectCatalogs.labelOf(
            ProspectCatalogs.previousSoftware,
            initial!.previousSoftware,
          ),
  );
  late final sourceOther = TextEditingController(text: initial?.sourceOther);

  /// Stable source code (`facebook`, `other`, ...) or null.
  late final source = Rxn<String>(
    (initial?.source ?? '').trim().isEmpty ? null : initial!.source,
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
    'source',
    'source_other',
    'previous_software',
    'notes',
    'sales_stage_id',
    'product_ids',
  };

  /// Set after the first submit attempt so non-text fields show errors.
  final showValidation = false.obs;

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

  void clearServerError(String field) => serverErrors.remove(field);

  // --- Field validators (client rules + server message for that field) ---

  // Length limits match the API's validation rules.
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

  String? validateBusinessActivity(String? v) =>
      serverErrors['business_activity'] ?? Validators.maxLength(v, 150);

  String? validatePreviousSoftware(String? v) =>
      serverErrors['previous_software'] ?? Validators.maxLength(v, 150);

  String? validateSourceOther(String? v) =>
      serverErrors['source_other'] ?? Validators.maxLength(v, 150);

  void selectSource(String? code) {
    source.value = code;
    serverErrors.remove('source');
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
    check('business_activity', validateBusinessActivity(businessActivity.text));
    check('previous_software', validatePreviousSoftware(previousSoftware.text));
    check('source_other', validateSourceOther(sourceOther.text));
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
    businessActivity: ProspectCatalogs.codeFor(
      ProspectCatalogs.businessActivities,
      businessActivity.text,
    ),
    source: source.value,
    sourceOther: sourceOther.text,
    previousSoftware: ProspectCatalogs.codeFor(
      ProspectCatalogs.previousSoftware,
      previousSoftware.text,
    ),
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
      businessActivity,
      previousSoftware,
      sourceOther,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
