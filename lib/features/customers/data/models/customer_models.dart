import '../../../../app/l10n/l10n.dart';
import '../../../../core/models/named_ref.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../../scheduling/data/models/appointment.dart';

/// A product the customer owns (`products[]` of the customer profile).
class CustomerProduct {
  const CustomerProduct({
    required this.id,
    required this.name,
    this.purchasedAt,
  });

  final int id;
  final String name;
  final DateTime? purchasedAt;

  factory CustomerProduct.fromJson(JsonMap json) => CustomerProduct(
    id: asInt(json['id']),
    name: asString(json['name']),
    purchasedAt: asDateTimeOrNull(json['purchased_at']),
  );
}

/// A website (portal) login linked to a customer. Customer identities are
/// separate from employee access; only their status is shown here.
class PortalAccount {
  const PortalAccount({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isActive = true,
    this.lastLoginAt,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;
  final DateTime? lastLoginAt;

  factory PortalAccount.fromJson(JsonMap json) => PortalAccount(
    id: asInt(json['id']),
    name: asString(json['name']),
    email: asString(json['email']),
    phone: asStringOrNull(json['phone']),
    isActive: asBool(json['is_active'], fallback: true),
    lastLoginAt: asDateTimeOrNull(json['last_login_at']),
  );
}

/// Trial access granted to a customer for one product.
class Trial {
  const Trial({
    required this.id,
    required this.product,
    required this.state,
    this.prospectId,
    this.url,
    this.startsAt,
    this.endsAt,
    this.revokedAt,
    this.createdBy,
    this.internalNotes,
  });

  final int id;
  final int? prospectId;
  final NamedRef product;

  /// `active`, `scheduled`, `expired` or `revoked` (computed by the server).
  final String state;
  final String? url;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? revokedAt;
  final String? createdBy;
  final String? internalNotes;

  bool get isActive => state == 'active';

  /// Can still be revoked (not already ended).
  bool get canRevoke => state == 'active' || state == 'scheduled';

  String get stateLabel => switch (state) {
    'active' => tr.wfTrialActive,
    'scheduled' => tr.wfTrialScheduled,
    'expired' => tr.wfStatusExpired,
    'revoked' => tr.wfTrialRevoked,
    _ => state,
  };

  factory Trial.fromJson(JsonMap json) => Trial(
    id: asInt(json['id']),
    prospectId: asIntOrNull(json['prospect_id']),
    product:
        NamedRef.fromJsonOrNull(json['product']) ??
        const NamedRef(id: 0, name: ''),
    state: asString(json['state']),
    url: asStringOrNull(json['url']),
    startsAt: asDateTimeOrNull(json['starts_at']),
    endsAt: asDateTimeOrNull(json['ends_at']),
    revokedAt: asDateTimeOrNull(json['revoked_at']),
    createdBy: asStringOrNull(json['created_by']),
    internalNotes: asStringOrNull(json['internal_notes']),
  );
}

/// `GET /customers/{id}`: the prospect record (same id) with everything the
/// customer owns.
class CustomerProfile {
  const CustomerProfile({
    required this.prospect,
    this.products = const [],
    this.portalAccounts = const [],
    this.trials = const [],
    this.appointments = const [],
  });

  final Prospect prospect;
  final List<CustomerProduct> products;
  final List<PortalAccount> portalAccounts;
  final List<Trial> trials;
  final List<Appointment> appointments;

  bool get hasPortalAccount => portalAccounts.any((a) => a.isActive);

  factory CustomerProfile.fromJson(JsonMap json) => CustomerProfile(
    prospect: Prospect.fromJson(
      asMapOrNull(json['prospect']) ?? const <String, dynamic>{},
    ),
    products: asList(json['products'], CustomerProduct.fromJson),
    portalAccounts: asList(json['portal_accounts'], PortalAccount.fromJson),
    trials: asList(json['trials'], Trial.fromJson),
    appointments: asList(json['appointments'], Appointment.fromJson),
  );
}

/// Body of `POST /prospects/{id}/convert`.
class ConvertPayload {
  const ConvertPayload({
    this.productIds = const [],
    this.note,
    this.wonStageId,
  });

  /// Products the customer purchased (links them with a purchase date).
  final List<int> productIds;
  final String? note;
  final int? wonStageId;

  JsonMap toJson() {
    final text = note?.trim();
    return {
      'product_ids': productIds,
      if (text != null && text.isNotEmpty) 'note': text,
      'won_stage_id': ?wonStageId,
    };
  }
}

/// Body of `POST /prospects/{id}/trials`.
class TrialPayload {
  const TrialPayload({
    this.productId,
    this.productIds,
    this.url,
    this.startsAt,
    this.endsAt,
    this.internalNotes,
  });

  final int? productId;
  final List<int>? productIds;

  /// Deprecated: the demo link is the product's fixed `demo_url`; the server
  /// ignores manual links. Only sent when a caller still provides one.
  final String? url;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? internalNotes;

  JsonMap toJson() {
    final notes = internalNotes?.trim();
    final manualUrl = url?.trim();
    return {
      if (productIds != null && productIds!.isNotEmpty)
        'product_ids': productIds
      else if (productId != null)
        'product_id': productId,
      if (manualUrl != null && manualUrl.isNotEmpty) 'url': manualUrl,
      if (startsAt != null) 'starts_at': toApiDateTime(startsAt!),
      if (endsAt != null) 'ends_at': toApiDateTime(endsAt!),
      if (notes != null && notes.isNotEmpty) 'internal_notes': notes,
    };
  }
}
