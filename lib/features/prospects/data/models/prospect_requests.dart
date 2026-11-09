import '../../../../core/utils/json_utils.dart';
import '../../../settings/data/models/loss_reason.dart';
import '../../../settings/data/models/sales_stage.dart';
import '../../../../app/l10n/l10n.dart';

/// Body of POST `/prospects` and PUT `/prospects/{id}`.
class ProspectPayload {
  const ProspectPayload({
    required this.companyName,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.businessActivity,
    this.source,
    this.sourceOther,
    this.previousSoftware,
    this.notes,
    this.salesStageId,
    this.productIds = const [],
  });

  final String companyName;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? businessActivity;
  final String? source;

  /// Only meaningful (and only kept by the API) when [source] is `other`.
  final String? sourceOther;
  final String? previousSoftware;
  final String? notes;

  /// Only sent on creation. Later changes go through `change-stage` so the
  /// history is recorded (the API refuses a different stage on PUT).
  final int? salesStageId;

  /// Replaces the prospect's whole product list.
  final List<int> productIds;

  static String? _clean(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  JsonMap toJson({required bool isCreate}) => {
    'name': companyName.trim(),
    'contact_person': _clean(contactName),
    'phone': _clean(phone),
    'email': _clean(email),
    'address': _clean(address),
    'city': _clean(city),
    'business_activity': _clean(businessActivity),
    'source': _clean(source),
    'source_other': source == 'other' ? _clean(sourceOther) : null,
    'previous_software': _clean(previousSoftware),
    'notes': _clean(notes),
    if (isCreate) 'sales_stage_id': salesStageId,
    'product_ids': productIds,
  };
}

/// Body of POST `/prospects/{id}/change-stage`.
class StageTransitionRequest {
  const StageTransitionRequest({
    required this.stageId,
    this.lossReasonId,
    this.lossDetails,
  });

  final int stageId;
  final int? lossReasonId;

  /// API `loss_note`.
  final String? lossDetails;

  JsonMap toJson() {
    final details = lossDetails?.trim();
    return {
      'sales_stage_id': stageId,
      if (lossReasonId != null) 'loss_reason_id': lossReasonId,
      if (details != null && details.isNotEmpty) 'loss_note': details,
    };
  }
}

/// Client-side check of the lost-stage rule. The backend enforces the same
/// rule; this only prevents sending a request that is known to fail.
class StageTransitionRules {
  const StageTransitionRules._();

  /// Returns an error message, or `null` when the transition can be sent.
  static String? validate({
    required SalesStage? target,
    required int? currentStageId,
    LossReason? lossReason,
    String? lossDetails,
  }) {
    if (target == null) return tr.validSelectStage;
    if (target.id == currentStageId) {
      return tr.validAlreadyInStage;
    }
    if (!target.isActive) return tr.validStageDisabled;
    if (target.isLost) {
      if (lossReason == null) {
        return tr.validLossReasonRequiredForLost;
      }
      if (lossReason.requiresDetails &&
          (lossDetails == null || lossDetails.trim().isEmpty)) {
        return tr.validReasonNeedsDetails;
      }
    }
    return null;
  }

  static StageTransitionRequest build({
    required SalesStage target,
    LossReason? lossReason,
    String? lossDetails,
  }) => StageTransitionRequest(
    stageId: target.id,
    // Loss data is only meaningful (and only accepted) for a lost stage.
    lossReasonId: target.isLost ? lossReason?.id : null,
    lossDetails: target.isLost ? lossDetails : null,
  );
}
