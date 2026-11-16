# -*- coding: utf-8 -*-
"""Hand-written translations for the few messages the extractor skipped."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import add_many, edit  # noqa: E402

add_many([
    dict(key='errNotJson',
         fr="Le serveur a répondu, mais pas en JSON. Vérifiez que l'adresse se termine par /api/v1.",
         en='The server answered, but not in JSON. Check that the address ends with /api/v1.',
         ar='ردّ الخادم، لكن ليس بصيغة JSON. تأكد من أن العنوان ينتهي بـ /api/v1.'),
    dict(key='countProspects', params={'count': 'int'},
         fr='{count, plural, =0{Aucun prospect} one{1 prospect} other{{count} prospects}}',
         en='{count, plural, =0{No prospects} one{1 prospect} other{{count} prospects}}',
         ar='{count, plural, =0{لا يوجد عملاء محتملون} one{عميل محتمل واحد} two{عميلان محتملان} few{{count} عملاء محتملين} many{{count} عميلًا محتملًا} other{{count} عميل محتمل}}'),
    dict(key='countActivities', params={'count': 'int'},
         fr='{count, plural, =0{Aucune activité} one{1 activité} other{{count} activités}}',
         en='{count, plural, =0{No activities} one{1 activity} other{{count} activities}}',
         ar='{count, plural, =0{لا توجد أنشطة} one{نشاط واحد} two{نشاطان} few{{count} أنشطة} many{{count} نشاطًا} other{{count} نشاط}}'),
    dict(key='activitiesCountSubtitle', params={'count': 'int'},
         fr='{count, plural, one{{count} activité} other{{count} activités}} — appels, rendez-vous, messages et notes',
         en='{count, plural, one{{count} activity} other{{count} activities}} — calls, appointments, messages and notes',
         ar='{count, plural, one{نشاط واحد} two{نشاطان} few{{count} أنشطة} many{{count} نشاطًا} other{{count} نشاط}} — مكالمات ومواعيد ورسائل وملاحظات'),
    dict(key='pipelineCountSubtitle', params={'count': 'int'},
         fr='{count, plural, one{{count} prospect} other{{count} prospects}} · glissez une carte vers une autre étape pour la déplacer',
         en='{count, plural, one{{count} prospect} other{{count} prospects}} · drag a card to another stage to move it',
         ar='{count, plural, one{عميل محتمل واحد} two{عميلان محتملان} few{{count} عملاء محتملين} many{{count} عميلًا محتملًا} other{{count} عميل محتمل}} · اسحب بطاقة إلى مرحلة أخرى لنقلها'),
    dict(key='donutProspects', fr='prospects', en='prospects', ar='عميل محتمل'),
    dict(key='reasonLine', params={'note': 'Object'}, fr='Raison : {note}', en='Reason: {note}', ar='السبب: {note}'),
    dict(key='lossReasonLine', params={'reason': 'Object'}, fr='Motif : {reason}', en='Reason: {reason}',
         ar='السبب: {reason}'),
    dict(key='deactivateStageIntro',
         fr="L'étape ne pourra plus être choisie pour de nouveaux changements.",
         en='The stage can no longer be chosen for new changes.',
         ar='لن يمكن اختيار المرحلة لتغييرات جديدة.'),
    dict(key='deactivateStageProspects', params={'count': 'int'},
         fr='{count, plural, one{1 prospect y est actuellement et y restera.} other{{count} prospects y sont actuellement et y resteront.}}',
         en='{count, plural, one{1 prospect is currently in it and will stay there.} other{{count} prospects are currently in it and will stay there.}}',
         ar='{count, plural, one{يوجد عميل محتمل واحد فيها حاليًا وسيبقى فيها.} two{يوجد عميلان محتملان فيها حاليًا وسيبقيان فيها.} few{يوجد {count} عملاء محتملين فيها حاليًا وسيبقون فيها.} many{يوجد {count} عميلًا محتملًا فيها حاليًا وسيبقون فيها.} other{يوجد {count} عميل محتمل فيها حاليًا وسيبقون فيها.}}'),
    dict(key='deactivateStageOutro', fr="L'historique est conservé.", en='The history is kept.',
         ar='يُحتفظ بالسجل.'),
])

edit('lib/core/network/api_interceptors.dart',
     "        error: const FormatException(\n"
     "          'Le serveur a répondu, mais pas en JSON. '\n"
     "          'Vérifiez que l\\'adresse se termine par /api/v1.',\n"
     "        ),",
     "        error: FormatException(tr.errNotJson),")
edit('lib/features/activities/presentation/pages/activities_page.dart',
     "? '${Formatters.plural(controller.page.value.total, 'activité')} — appels, rendez-vous, messages et notes'",
     "? tr.activitiesCountSubtitle(controller.page.value.total)")
edit('lib/features/dashboard/presentation/pages/dashboard_page.dart',
     "centerLabel: 'prospects',", "centerLabel: tr.donutProspects,")
edit('lib/features/follow_ups/presentation/dialogs/follow_up_dialogs.dart',
     "            '${c.followUp.prospect?.companyName ?? ''} — prévue le '\n"
     "            '${Formatters.dateTime(c.followUp.dueAt)}',",
     "            tr.companyDueOn(c.followUp.prospect?.companyName ?? '', Formatters.dateTime(c.followUp.dueAt)),")
edit('lib/features/follow_ups/presentation/widgets/follow_up_widgets.dart',
     "                    '${followUp.status == FollowUpStatus.cancelled ? 'Raison' : 'Résultat'} : '\n"
     "                    '${followUp.closingNote}',",
     "                    followUp.status == FollowUpStatus.cancelled\n"
     "                        ? tr.reasonLine(followUp.closingNote!)\n"
     "                        : tr.outcomeLine(followUp.closingNote!),")
edit('lib/features/pipeline/presentation/pages/pipeline_page.dart',
     "? '${Formatters.plural(controller.totalProspects, 'prospect')} · '\n"
     "                      'glissez une carte vers une autre étape pour la déplacer'",
     "? tr.pipelineCountSubtitle(controller.totalProspects)")
edit('lib/features/prospects/presentation/pages/prospects_page.dart',
     "? Formatters.plural(controller.page.value.total, 'prospect')",
     "? tr.countProspects(controller.page.value.total)")
edit('lib/features/prospects/presentation/pages/prospects_page.dart',
     "AppFeedback.success('« ${updated.companyName} » est passé à l\\'étape « ${updated.stage?.name ?? ''} ».');",
     "AppFeedback.success(tr.prospectMovedTo(updated.companyName, updated.stage?.name ?? ''));")
edit('lib/features/prospects/presentation/pages/prospect_details_page.dart',
     "'Motif : ${h.lossReason!.label}'", "tr.lossReasonLine(h.lossReason!.label)")
edit('lib/features/prospects/presentation/pages/prospect_details_page.dart',
     "Formatters.plural(c.activitiesTotal.value, tr.activityWord)", "tr.countActivities(c.activitiesTotal.value)")
edit('lib/features/settings/presentation/pages/stages_settings_page.dart',
     "            'L\\'étape ne pourra plus être choisie pour de nouveaux changements. '\n"
     "            '${count > 0 ? '$count prospect(s) y sont actuellement et y resteront. ' : ''}'\n"
     "            'L\\'historique est conservé.',",
     "            [\n"
     "              tr.deactivateStageIntro,\n"
     "              if (count > 0) tr.deactivateStageProspects(count),\n"
     "              tr.deactivateStageOutro,\n"
     "            ].join(' '),")
print('manual step 1 ok')
