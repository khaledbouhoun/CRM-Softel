# -*- coding: utf-8 -*-
"""Adds the strings of the staff-app alignment phase to the three ARB files
AND to the generated localization classes (so the project compiles even
before `flutter gen-l10n` is run; running it later produces the same API).

Re-runnable: existing keys are overwritten in the ARB files and skipped in
the generated Dart files.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import arb  # noqa: E402

ROOT = arb.ROOT


def E(key, fr, en, ar):
    return dict(key=key, fr=fr, en=en, ar=ar)


ENTRIES = [
    # --- interventions: chat, attachments, closure
    E('ivSupport', 'Support', 'Support', 'الدعم'),
    E('ivSystem', 'Système', 'System', 'النظام'),
    E('ivEventStatusFull', 'Statut modifié de {from} à {to} par {actor} à {time}',
      'Status changed from {from} to {to} by {actor} at {time}',
      'غيّر {actor} الحالة من {from} إلى {to} في {time}'),
    E('ivEventStatusTo', 'Statut modifié en {to} par {actor} à {time}',
      'Status changed to {to} by {actor} at {time}',
      'غيّر {actor} الحالة إلى {to} في {time}'),
    E('ivEventReopened', 'Intervention rouverte par {actor} à {time}',
      'Intervention reopened by {actor} at {time}',
      'أعاد {actor} فتح التدخل في {time}'),
    E('ivAttachFiles', 'Joindre des fichiers', 'Attach files', 'إرفاق ملفات'),
    E('ivAttachLimit', '{max} fichiers maximum par message.',
      'At most {max} files per message.', '{max} ملفات كحد أقصى في الرسالة.'),
    E('ivRemoveFile', 'Retirer ce fichier', 'Remove this file', 'إزالة هذا الملف'),
    E('ivDownload', 'Télécharger', 'Download', 'تنزيل'),
    E('ivPreview', 'Aperçu', 'Preview', 'معاينة'),
    E('ivViewPdf', 'Ouvrir le PDF', 'Open PDF', 'فتح ملف PDF'),
    E('ivFileSaved', 'Fichier enregistré : {path}', 'File saved: {path}',
      'تم حفظ الملف: {path}'),
    E('ivImageError', "Impossible d'afficher l'image.",
      'Could not display the image.', 'تعذر عرض الصورة.'),
    E('ivClosedBanner',
      'Cette intervention est clôturée. Les nouvelles réponses sont désactivées.',
      'This intervention is closed. New replies are disabled.',
      'تم إغلاق هذا التدخل. الردود الجديدة معطلة.'),
    E('ivReopen', "Rouvrir l'intervention", 'Reopen intervention',
      'إعادة فتح التدخل'),
    E('ivReopenBody',
      'Les réponses seront de nouveau possibles pour vous et pour le client.',
      'Replies will be enabled again for you and the customer.',
      'ستُفعَّل الردود من جديد لك وللعميل.'),
    E('ivReopenNote', 'Note (facultative)', 'Note (optional)', 'ملاحظة (اختياري)'),
    E('ivReopened', 'Intervention rouverte.', 'Intervention reopened.',
      'تمت إعادة فتح التدخل.'),
    # --- products: filtering, packs, fixed demo link
    E('prDemoLink', 'Lien de la démo', 'Demo link', 'رابط العرض التجريبي'),
    E('prDemoLinkHint', 'Lien fixe défini sur le produit.',
      'Fixed link set on the product.', 'رابط ثابت محدد في المنتج.'),
    E('prNoDemoLink', "Ce produit n'a pas de lien de démo.",
      'This product has no demo link.', 'لا يملك هذا المنتج رابط عرض تجريبي.'),
    E('prNoDemoProducts', 'Aucun produit avec démo pour ce client.',
      'No demo-enabled product for this customer.',
      'لا يوجد منتج بعرض تجريبي لهذا العميل.'),
    E('prNoLinkedProducts', 'Aucun produit associé à ce client.',
      'No product linked to this customer.', 'لا توجد منتجات مرتبطة بهذا العميل.'),
    E('prFilteredByCustomer', 'Produits associés à ce client uniquement.',
      'Showing only the products linked to this customer.',
      'تُعرض المنتجات المرتبطة بهذا العميل فقط.'),
    E('prCustomersFilteredByProduct', 'Clients liés à ce produit uniquement.',
      'Showing only customers linked to this product.',
      'تُعرض العملاء المرتبطون بهذا المنتج فقط.'),
    E('prPackReplaced', '« {name} » a été désélectionné : un seul produit par pack.',
      '“{name}” was unchecked: only one product per pack.',
      'تم إلغاء تحديد «{name}»: منتج واحد فقط لكل حزمة.'),
    E('prPackHint', 'Un seul produit par pack.', 'One product per pack.',
      'منتج واحد لكل حزمة.'),
    # --- product releases
    E('navReleases', 'Mises à jour produits', 'Product releases', 'إصدارات المنتجات'),
    E('rlSubtitle', "Versions publiées de vos produits, fichiers d'installation et audience.",
      'Published product versions, installers and audience.',
      'إصدارات المنتجات المنشورة وملفات التثبيت والجمهور.'),
    E('rlNew', 'Nouvelle version', 'New release', 'إصدار جديد'),
    E('rlEdit', 'Modifier la version', 'Edit release', 'تعديل الإصدار'),
    E('rlVersion', 'Numéro de version', 'Version number', 'رقم الإصدار'),
    E('rlVersionRequired', 'Numéro de version obligatoire.',
      'Version number is required.', 'رقم الإصدار مطلوب.'),
    E('rlDate', 'Date de sortie', 'Release date', 'تاريخ الإصدار'),
    E('rlChangelog', 'Notes de version', 'Changelog', 'ملاحظات الإصدار'),
    E('rlAudience', 'Audience', 'Audience', 'الجمهور'),
    E('rlAudienceAll', 'Tous les clients', 'All customers', 'جميع العملاء'),
    E('rlAudienceOwned', 'Clients propriétaires du produit',
      'Customers who own the product', 'العملاء الذين يملكون المنتج'),
    E('rlAudienceSpecific', 'Clients précis', 'Specific customers', 'عملاء محددون'),
    E('rlCustomers', 'Clients concernés', 'Selected customers', 'العملاء المحددون'),
    E('rlCustomersRequired', 'Choisissez au moins un client.',
      'Choose at least one customer.', 'اختر عميلاً واحداً على الأقل.'),
    E('rlInstaller', "Fichier d'installation", 'Installer file', 'ملف التثبيت'),
    E('rlInstallerHint', '.exe, .zip ou .rar', '.exe, .zip or .rar', '.exe أو .zip أو .rar'),
    E('rlPickInstaller', 'Choisir un fichier', 'Choose a file', 'اختيار ملف'),
    E('rlRemoveInstaller', "Retirer l'installateur", 'Remove installer',
      'إزالة ملف التثبيت'),
    E('rlExternalUrl', 'Lien de téléchargement externe', 'External download link',
      'رابط تنزيل خارجي'),
    E('rlPublished', 'Publiée', 'Published', 'منشور'),
    E('rlDraft', 'Brouillon', 'Draft', 'مسودة'),
    E('rlNoReleases', 'Aucune version', 'No releases yet', 'لا توجد إصدارات'),
    E('rlNoReleasesHint', "Créez la première version d'un produit.",
      'Create the first release of a product.', 'أنشئ أول إصدار لمنتج.'),
    E('rlDeleteTitle', 'Supprimer cette version ?', 'Delete this release?',
      'حذف هذا الإصدار؟'),
    E('rlDeleteBody', 'Les clients ne la verront plus.',
      'Customers will no longer see it.', 'لن يراه العملاء بعد الآن.'),
    E('rlSaved', 'Version enregistrée.', 'Release saved.', 'تم حفظ الإصدار.'),
    E('rlDeleted', 'Version supprimée.', 'Release deleted.', 'تم حذف الإصدار.'),
    E('rlUploading', 'Envoi du fichier…', 'Uploading file…', 'جارٍ رفع الملف…'),
    E('rlAllProducts', 'Tous les produits', 'All products', 'كل المنتجات'),
    # --- help tooltips and fixed appointment types
    E('helpTooltip', 'Aide', 'Help', 'مساعدة'),
    E('helpExample', 'Exemple', 'Example', 'مثال'),
    E('helpFields', 'Champs', 'Fields', 'الحقول'),
    E('helpUnavailable', 'Aide indisponible pour cette section.',
      'Help is not available for this section.', 'المساعدة غير متوفرة لهذا القسم.'),
    E('wfFixedTypesNote',
      'Les 4 types (Démo, Réunion, Formation, Accompagnement) sont fixes. Vous pouvez seulement ajuster la durée, la couleur et la réservation en ligne.',
      'The 4 types (Demo, Meeting, Training, Accompaniment) are fixed. You can only adjust duration, color and online booking.',
      'الأنواع الأربعة (عرض تجريبي، اجتماع، تدريب، مرافقة) ثابتة. يمكنك فقط تعديل المدة واللون والحجز عبر الإنترنت.'),
]

PH = re.compile(r'\{(\w+)\}')


def params(text):
    seen = []
    for m in PH.findall(text):
        if m not in seen:
            seen.append(m)
    return seen


def esc(text):
    return text.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')


def dart_expr(text):
    return PH.sub(lambda m: '${%s}' % m.group(1), esc(text))


def patch_dart():
    base = os.path.join(ROOT, 'lib', 'l10n')

    def read(name):
        with open(os.path.join(base, name), 'rb') as f:
            raw = f.read().decode('utf-8')
        return raw, ('\r\n' in raw)

    def write(name, raw):
        with open(os.path.join(base, name), 'wb') as f:
            f.write(raw.encode('utf-8'))

    abstract, crlf = read('app_localizations.dart')
    nl = '\r\n' if crlf else '\n'
    new_abstract = []
    for e in ENTRIES:
        if re.search(r'\b(get\s+%s|%s\()' % (e['key'], e['key']), abstract):
            continue
        ps = params(e['fr'])
        sig = ('String %s(%s);' % (e['key'], ', '.join('Object %s' % p for p in ps))
               if ps else 'String get %s;' % e['key'])
        doc = e['fr'].replace(nl, ' ')
        new_abstract.append(
            "  /// No description provided for @%s.%s  ///%s  /// In fr, this message translates to:%s"
            "  /// **'%s'**%s  %s%s%s" % (e['key'], nl, nl, nl, esc(doc), nl, sig, nl, nl))
    if new_abstract:
        idx = abstract.rindex('}' + nl + nl + 'class _AppLocalizationsDelegate')
        abstract = abstract[:idx] + nl.join(new_abstract).rstrip(nl) + nl + abstract[idx:]
        # keep a blank line before the closing brace like the generator does
        write('app_localizations.dart', abstract)

    for lang in ('fr', 'en', 'ar'):
        name = 'app_localizations_%s.dart' % lang
        raw, crlf = read(name)
        nl = '\r\n' if crlf else '\n'
        chunks = []
        for e in ENTRIES:
            if re.search(r'\b(get\s+%s\b|\s%s\()' % (e['key'], e['key']), raw):
                continue
            ps = params(e['fr'])
            text = e[lang]
            if ps:
                chunks.append("  @override%s  String %s(%s) {%s    return '%s';%s  }" % (
                    nl, e['key'], ', '.join('Object %s' % p for p in ps), nl,
                    dart_expr(text), nl))
            else:
                chunks.append("  @override%s  String get %s => '%s';" % (nl, e['key'], esc(text)))
        if not chunks:
            continue
        end = raw.rstrip().rfind('}')
        body = raw[:end].rstrip() + nl + nl + (nl + nl).join(chunks) + nl + '}' + nl
        write(name, body)
    print('dart files patched (%d entries)' % len(ENTRIES))


if __name__ == '__main__':
    arb.add_many(ENTRIES)
    patch_dart()
