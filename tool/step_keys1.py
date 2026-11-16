# -*- coding: utf-8 -*-
"""Translation keys for the enhancement (prospect fields, search, linking, relance types, language)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import add_many  # noqa: E402


def k(key, fr, en, ar, params=None):
    d = dict(key=key, fr=fr, en=en, ar=ar)
    if params:
        d['params'] = params
    return d


O = 'Object'

add_many([
    # ---- prospect profile fields
    k('sectionBusinessProfile', 'Profil commercial', 'Business profile', 'الملف التجاري'),
    k('fieldBusinessActivity', "Activité de l'entreprise", 'Business activity', 'نشاط الشركة'),
    k('businessActivityHint', 'Choisir ou saisir une activité', 'Pick or type an activity', 'اختر أو اكتب نشاطًا'),
    k('fieldSource', 'Source du prospect', 'Prospect source', 'مصدر العميل المحتمل'),
    k('fieldSourceOther', 'Précisez la source', 'Specify the source', 'حدّد المصدر'),
    k('fieldPreviousSoftware', 'Logiciel utilisé auparavant', 'Previous software', 'البرنامج المستخدم سابقًا'),
    k('previousSoftwareHint', 'Choisir ou saisir un logiciel', 'Pick or type a software', 'اختر أو اكتب برنامجًا'),
    k('notSpecified', 'Non renseigné', 'Not specified', 'غير محدد'),
    k('allSources', 'Toutes les sources', 'All sources', 'كل المصادر'),
    k('baWholesale', 'Commerce de gros', 'Wholesale trade', 'تجارة الجملة'),
    k('baRetail', 'Commerce de détail', 'Retail', 'تجارة التجزئة'),
    k('baManufacturing', 'Industrie / production', 'Manufacturing', 'صناعة / إنتاج'),
    k('baConstruction', 'BTP / construction', 'Construction', 'بناء وأشغال عمومية'),
    k('baServices', 'Services', 'Services', 'خدمات'),
    k('srcFacebook', 'Facebook', 'Facebook', 'فيسبوك'),
    k('srcInstagram', 'Instagram', 'Instagram', 'إنستغرام'),
    k('srcFriendReferral', 'Ami / recommandation personnelle', 'Friend / personal referral',
      'صديق / توصية شخصية'),
    k('srcCustomerReferral', "Recommandation d'un client existant", 'Existing customer referral',
      'توصية من عميل حالي'),
    k('srcWebsite', 'Site web', 'Website', 'الموقع الإلكتروني'),
    k('srcPhoneCall', 'Appel téléphonique', 'Phone call', 'مكالمة هاتفية'),
    k('swSage', 'Sage', 'Sage', 'Sage'),
    k('swPcCompta', 'PC Compta', 'PC Compta', 'PC Compta'),
    k('swExcel', 'Excel', 'Excel', 'Excel'),
    k('swOtherSoftware', 'Autre logiciel de gestion', 'Another management software', 'برنامج تسيير آخر'),
    k('swNone', 'Aucun logiciel', 'No previous software', 'لا يوجد برنامج سابق'),

    # ---- prospect search dialog
    k('searchProspectTitle', 'Rechercher un prospect', 'Search a prospect', 'البحث عن عميل محتمل'),
    k('searchProspectHint', 'Nom, société, téléphone ou n° de prospect…',
      'Name, company, phone or prospect ID…', 'الاسم، الشركة، الهاتف أو رقم العميل…'),
    k('searchProspectIdle', 'Saisissez un nom, une société, un numéro de téléphone ou un n° de prospect.',
      'Type a name, company, phone number or prospect ID.', 'اكتب اسمًا أو شركة أو رقم هاتف أو رقم عميل.'),
    k('searchProspectEmpty', 'Aucun prospect trouvé', 'No prospect found', 'لم يتم العثور على عميل محتمل'),
    k('searchProspectMore', 'Affinez la recherche pour voir les autres résultats ({total} au total).',
      'Refine the search to see the other results ({total} in total).',
      'دقّق البحث لعرض باقي النتائج (الإجمالي {total}).', {'total': O}),
    k('searchAllStagesNote', 'La recherche porte sur toutes les étapes (gagnés et perdus inclus).',
      'The search covers all stages (won and lost included).',
      'يشمل البحث جميع المراحل (بما فيها المكسوبة والخاسرة).'),
    k('prospectIdShort', 'N° {id}', 'ID {id}', 'رقم {id}', {'id': O}),
    k('prospectOptionalLabel', 'Prospect (optionnel)', 'Prospect (optional)', 'العميل المحتمل (اختياري)'),
    k('pickProspect', 'Choisir un prospect', 'Choose a prospect', 'اختيار عميل محتمل'),

    # ---- activities: native creation, linking
    k('activityTitleRequired', 'Titre / résumé *', 'Title / summary *', 'العنوان / الملخص *'),
    k('activityTitleHint', 'Ex. : appel du client au sujet du devis', 'E.g. customer called about the quotation',
      'مثال: اتصال العميل بخصوص عرض السعر'),
    k('activityDiscussionLabel', 'Discussion, réponse du client, notes', 'Discussion, customer response, notes',
      'النقاش، رد العميل، ملاحظات'),
    k('colTitle', 'Titre', 'Title', 'العنوان'),
    k('linkStatusLinked', 'Lié', 'Linked', 'مرتبط'),
    k('linkStatusUnlinked', 'Non lié', 'Unlinked', 'غير مرتبط'),
    k('linkToProspect', 'Lier à un prospect', 'Link to prospect', 'ربط بعميل محتمل'),
    k('changeLinkedProspect', 'Changer le prospect lié', 'Change linked prospect', 'تغيير العميل المحتمل المرتبط'),
    k('linkedProspectLabel', 'Prospect lié', 'Linked prospect', 'العميل المحتمل المرتبط'),
    k('noProspectLinked', 'Aucun prospect lié', 'No linked prospect', 'لا يوجد عميل محتمل مرتبط'),
    k('openProspect', 'Ouvrir le prospect', 'Open prospect', 'فتح العميل المحتمل'),
    k('activityDetails', "Détails de l'activité", 'Activity details', 'تفاصيل النشاط'),
    k('activityLinkedTo', 'Activité liée à « {name} ».', 'Activity linked to "{name}".',
      'تم ربط النشاط بـ «{name}».', {'name': O}),
    k('relinkTitle', 'Changer le prospect lié ?', 'Change the linked prospect?', 'تغيير العميل المحتمل المرتبط؟'),
    k('relinkBody', 'Cette activité est liée à « {from} ». La déplacer vers « {to} » ? Son contenu et sa date ne changent pas.',
      'This activity is linked to "{from}". Move it to "{to}"? Its content and date do not change.',
      'هذا النشاط مرتبط بـ «{from}». هل تريد نقله إلى «{to}»؟ لن يتغير محتواه ولا تاريخه.',
      {'from': O, 'to': O}),
    k('relinkConfirm', 'Déplacer', 'Move', 'نقل'),
    k('originLabel', 'Origine', 'Origin', 'المصدر'),
    k('originDirect', 'Saisie directe', 'Entered directly', 'إدخال مباشر'),
    k('originFollowUp', "Issue d'une relance", 'Converted from a follow-up', 'محوّل من متابعة'),
    k('activityFromFollowUpLocked', "Cette activité provient d'une relance : elle reste liée à son prospect.",
      'This activity comes from a follow-up: it stays with its prospect.',
      'هذا النشاط ناتج عن متابعة: يبقى مرتبطًا بعميله المحتمل.'),
    k('filterLinkAll', 'Toutes (liées ou non)', 'All (linked or not)', 'الكل (مرتبط أو غير مرتبط)'),
    k('filterLinkOnlyLinked', 'Liées à un prospect', 'Linked to a prospect', 'المرتبطة بعميل'),
    k('filterLinkOnlyUnlinked', 'Non liées', 'Unlinked', 'غير المرتبطة'),
    k('colLink', 'Prospect lié', 'Linked prospect', 'العميل المرتبط'),
    k('activityOccurredAt', 'Date et heure', 'Date and time', 'التاريخ والوقت'),
    k('createdOnLabel', 'Créée le', 'Created on', 'أُنشئ في'),
    k('linkedOnLabel', 'Liée le', 'Linked on', 'رُبط في'),
    k('typeLabelRequired', "Type d'activité *", 'Activity type *', 'نوع النشاط *'),

    # ---- follow-up types
    k('followUpTypeLabel', 'Type de relance', 'Follow-up type', 'نوع المتابعة'),
    k('followUpTypeRequired', 'Choisissez le type de relance.', 'Choose the follow-up type.',
      'اختر نوع المتابعة.'),
    k('followUpTypeMissing', 'Type non défini', 'Type not set', 'النوع غير محدد'),
    k('followUpCompletedKeepsType', "Le type de l'activité sera celui de la relance : {type}.",
      "The activity type will be the follow-up's: {type}.", 'سيكون نوع النشاط هو نوع المتابعة: {type}.',
      {'type': O}),
    k('activityTypeForLegacy', "Cette relance n'a pas de type : choisissez celui de l'activité.",
      'This follow-up has no type: choose the activity type.', 'هذه المتابعة بلا نوع: اختر نوع النشاط.'),
    k('followUpCompletedWithActivity', 'Relance terminée et activité enregistrée.',
      'Follow-up completed and activity recorded.', 'تم إنهاء المتابعة وتسجيل النشاط.'),
    k('colType', 'Type', 'Type', 'النوع'),

    # ---- language / theme
    k('settingsLanguage', 'Langue', 'Language', 'اللغة'),
    k('settingsLanguageHint', "Langue de l'interface. Le changement est immédiat.",
      'Interface language. The change is immediate.', 'لغة الواجهة. يتم التغيير فورًا.'),
    k('languageMenuTooltip', "Changer la langue", 'Change language', 'تغيير اللغة'),
    k('themeToggleToDark', 'Passer au thème sombre', 'Switch to dark theme', 'التبديل إلى الوضع الداكن'),
    k('themeToggleToLight', 'Passer au thème clair', 'Switch to light theme', 'التبديل إلى الوضع الفاتح'),
    k('settingsAboutBody', 'Seuls l\'adresse du serveur, la langue et le thème sont enregistrés sur ce poste.',
      'Only the server address, language and theme are saved on this computer.',
      'يُحفظ على هذا الحاسوب عنوان الخادم واللغة والمظهر فقط.'),
])
print('keys1 ok')
