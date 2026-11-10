import '../../../../app/l10n/l10n.dart';

/// A predefined choice stored as a stable code and shown in the UI language.
///
/// The database only ever holds [code] (or free text typed by the user), never
/// a translated label, so switching language never changes saved data.
class CatalogOption {
  const CatalogOption(this.code, this._label);

  final String code;
  final String Function() _label;

  String get label => _label();
}

/// Suggested values of the optional prospect profile fields. The API accepts
/// other values too (free text / new codes), so unknown codes are shown as-is.
class ProspectCatalogs {
  const ProspectCatalogs._();

  static const otherCode = 'other';

  static List<CatalogOption> get businessActivities => [
    CatalogOption('wholesale', () => tr.baWholesale),
    CatalogOption('retail', () => tr.baRetail),
    CatalogOption('manufacturing', () => tr.baManufacturing),
    CatalogOption('construction', () => tr.baConstruction),
    CatalogOption('services', () => tr.baServices),
    CatalogOption(otherCode, () => tr.optionOther),
  ];

  static List<CatalogOption> get sources => [
    CatalogOption('facebook', () => tr.srcFacebook),
    CatalogOption('instagram', () => tr.srcInstagram),
    CatalogOption('friend_referral', () => tr.srcFriendReferral),
    CatalogOption('customer_referral', () => tr.srcCustomerReferral),
    CatalogOption('website', () => tr.srcWebsite),
    CatalogOption('phone_call', () => tr.srcPhoneCall),
    CatalogOption(otherCode, () => tr.optionOther),
  ];

  static List<CatalogOption> get previousSoftware => [
    CatalogOption('sage', () => tr.swSage),
    CatalogOption('pc_compta', () => tr.swPcCompta),
    CatalogOption('excel', () => tr.swExcel),
    CatalogOption('other_software', () => tr.swOtherSoftware),
    CatalogOption('none', () => tr.swNone),
    CatalogOption(otherCode, () => tr.optionOther),
  ];

  /// Label of a stored value: the translation of a known code, otherwise the
  /// value itself (free text or a code added by a newer server).
  static String labelOf(List<CatalogOption> options, String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return tr.notSpecified;
    for (final o in options) {
      if (o.code == v) return o.label;
    }
    return v;
  }

  /// The code to store for what the user typed: the code of the option whose
  /// label matches (any language), otherwise the typed text unchanged.
  static String? codeFor(List<CatalogOption> options, String? text) {
    final t = text?.trim();
    if (t == null || t.isEmpty) return null;
    final lower = t.toLowerCase();
    for (final o in options) {
      if (o.label.toLowerCase() == lower || o.code == lower) return o.code;
    }
    return t;
  }

  static String? sourceLabel(String? code) => code == null || code.trim().isEmpty ? null : labelOf(sources, code);

  /// "Facebook", or "Other: Trade fair" when a detail was given.
  static String? sourceDisplay(String? code, String? other) {
    final base = sourceLabel(code);
    if (base == null) return null;
    final detail = other?.trim();
    return code == otherCode && detail != null && detail.isNotEmpty ? '$base — $detail' : base;
  }
}
