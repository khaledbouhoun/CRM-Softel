import '../../../../app/l10n/l10n.dart';
import '../../../../core/models/named_ref.dart';
import '../../../../core/utils/json_utils.dart';

/// A request a visitor submitted through the public website
/// (`/portal-requests`).
class PortalRequest {
  const PortalRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.company,
    required this.contactName,
    this.prospectId,
    this.portalAccountId,
    this.product,
    this.appointmentId,
    this.jobTitle,
    this.phone,
    this.email,
    this.wilaya,
    this.city,
    this.businessActivity,
    this.notes,
    this.source,
    this.customerMessage,
    this.createdAt,
  });

  final int id;

  /// `demo`, `quotation` or `trial`.
  final String type;

  /// `pending`, `scheduled`, `handled`, `rejected`, `cancelled`, `expired`...
  final String status;
  final int? prospectId;
  final int? portalAccountId;
  final NamedRef? product;
  final int? appointmentId;
  final String company;
  final String contactName;
  final String? jobTitle;
  final String? phone;
  final String? email;
  final String? wilaya;
  final String? city;
  final String? businessActivity;
  final String? notes;
  final String? source;
  final String? customerMessage;
  final DateTime? createdAt;

  bool get isDemo => type == 'demo';

  /// Quotation and trial requests are closed by the employee; demos change
  /// status through their appointment.
  bool get isActionable =>
      !isDemo && (status == 'pending' || status == 'scheduled');

  String get typeLabel => switch (type) {
    'demo' => tr.wfRequestDemo,
    'quotation' => tr.wfRequestQuotation,
    'trial' => tr.wfRequestTrial,
    _ => type,
  };

  String get statusLabel => switch (status) {
    'pending' => tr.wfReqPending,
    'scheduled' => tr.wfReqScheduled,
    'handled' => tr.wfReqHandled,
    'rejected' => tr.wfStatusRejected,
    'cancelled' => tr.wfStatusCancelled,
    'expired' => tr.wfStatusExpired,
    _ => status,
  };

  factory PortalRequest.fromJson(JsonMap json) => PortalRequest(
    id: asInt(json['id']),
    type: asString(json['type']),
    status: asString(json['status']),
    prospectId: asIntOrNull(json['prospect_id']),
    portalAccountId: asIntOrNull(json['portal_account_id']),
    product: NamedRef.fromJsonOrNull(json['product']),
    appointmentId: asIntOrNull(json['appointment_id']),
    company: asString(json['company']),
    contactName: asString(json['contact_name']),
    jobTitle: asStringOrNull(json['job_title']),
    phone: asStringOrNull(json['phone']),
    email: asStringOrNull(json['email']),
    wilaya: asStringOrNull(json['wilaya']),
    city: asStringOrNull(json['city']),
    businessActivity: asStringOrNull(json['business_activity']),
    notes: asStringOrNull(json['notes']),
    source: asStringOrNull(json['source']),
    customerMessage: asStringOrNull(json['customer_message']),
    createdAt: asDateTimeOrNull(json['created_at']),
  );
}
