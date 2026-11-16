# -*- coding: utf-8 -*-
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from arb import edit  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ---------------------------------------------------------------- API contract mapping
with open(os.path.join(ROOT, 'docs/API_CONTRACT.md'), 'a', encoding='utf-8', newline='\n') as f:
    f.write('''
## 7. Enhancement (2026-11-08): profile fields, activity types, linking

Authoritative description: `Laravel Backend/docs/API.md` (sections 3.4, 3.6,
3.7, 6, 8, 9). How the client uses it:

| Feature | API | Client |
|---|---|---|
| Prospect profile | `business_activity`, `source`, `source_other`, `previous_software` on `POST/PUT /prospects` (all nullable) | `Prospect`, `ProspectPayload`, `ProspectFormController`; labels in `ProspectCatalogs` |
| Stable codes | the API stores codes (`facebook`, `wholesale`, `sage`, ...) or free text, never translated labels | `ProspectCatalogs.codeFor()` turns what the user picked into the code; `labelOf()` shows it in the UI language |
| Prospect search | `GET /prospects?search=` matches name (company), `contact_person` (full name), phone (also digits only), id; no stage filter | one dialog, `showProspectSearchDialog`, used by every picker, the pipeline and the top-bar search |
| Prospect filters | `source`, `business_activity`, `previous_software` | `ProspectFilter` |
| Follow-up type | `activity_type` = `call` / `appointment` / `message` (null on old rows) on create / update | `FollowUp.activityType`, `FollowUpFormController.type` |
| Complete a follow-up | `POST /follow-ups/{id}/complete` with `create_activity: true` creates the activity **in the same transaction** with the follow-up's type and prospect | `CompleteFollowUpController` (one request; no second call) |
| Native activity | `POST /activities` (`title` required, `prospect_id` optional) | `ActivityFormController`; the client always uses this route |
| Link an activity | `POST /activities/{id}/link-prospect` `{prospect_id, confirm_relink?}` | `ActivityLinkController` + `linkActivityToProspect()` (asks for confirmation before moving an already linked activity) |
| Activity state | `is_linked`, `origin` (`direct` / `follow_up`), `follow_up_id`, `linked_at` | `Activity.isLinked`, `Activity.origin` |
| Legacy `meeting` | same meaning as `appointment` | `ActivityType.meeting.canonical == appointment` |

Errors specific to this feature: `409 ACTIVITY_ALREADY_LINKED` (moving without
`confirm_relink`) and `422 ACTIVITY_LINK_LOCKED` (moving an activity that came
from a follow-up).
''')

# ---------------------------------------------------------------- README
edit('README.md', "* **UI language: French.** Code, comments and documentation are in English.",
     "* **Languages: Arabic (default), French, English.** Arabic is laid out right-to-left. The language\n"
     "  is switched in the top bar (or *Serveur & affichage*) without restarting and is remembered on\n"
     "  each computer. Code, comments and documentation are in English.")
edit('README.md', "> ⚠️ **API contract status.** No Laravel implementation or shared API\n"
     "> specification was available when this client was written. The client follows\n"
     "> an **assumed contract** based on standard Laravel conventions, documented in\n"
     "> full in [docs/API_CONTRACT.md](docs/API_CONTRACT.md). Compare it with the real\n"
     "> backend before going live; that document lists exactly which files to adapt\n"
     "> if anything differs.",
     "> **API contract.** The authoritative contract is the backend's\n"
     "> `Laravel Backend/docs/API.md`; [docs/API_CONTRACT.md](docs/API_CONTRACT.md) maps it onto this\n"
     "> client and lists the files to adapt if the API changes.")
edit('README.md', "## 3. Development", """## 2b. Languages, themes and the design system

* **Translations** live in `lib/l10n/app_{ar,fr,en}.arb` (French is the template). `flutter pub get`
  / `flutter run` regenerate `AppLocalizations` automatically; to regenerate by hand run
  `flutter gen-l10n`. UI code reads strings through `tr.<key>` (`lib/app/l10n/l10n.dart`), so
  controllers and widgets share one source. To add a string: add the key to the three ARB files
  (a test fails if one language is missing a key or a placeholder).
* **Switching language:** top bar → globe menu, or *Serveur & affichage → Langue*. The choice is
  stored in the local settings file (`language_code`); with nothing stored the app starts in Arabic.
* **Stored values are codes, not labels.** Activity types (`call`, `appointment`, `message`), prospect
  sources (`facebook`, `friend_referral`, ...), business activities and previous software are saved
  as stable codes (or free text); only the display is translated, so changing language never alters data.
* **Themes:** light and dark, switched with the moon / sun button in the top bar or in
  *Serveur & affichage → Affichage* (also *System*). Persisted per computer.
* **Design system:** `lib/app/theme/app_theme.dart`. Palette `#000000`, `#14213D` (navy surfaces
  and sidebar), `#FCA311` (accent: primary actions and selection), `#E5E5E5` (borders), `#FFFFFF`.
  `AppSpacing`, `AppRadius`, `AppShadows` hold the shared sizes; reusable widgets are in
  `lib/core/widgets`.

---

## 3. Development""")
edit('README.md', "| **Activités** | All activities, filter by type / period, search, open the related prospect, add an activity (optionally scheduling a follow-up). Activities are append-only. |",
     "| **Activités** | All activities (linked or not), filter by type / link / period, search, details dialog. Create an activity on its own (title, type call / appointment / message, date, discussion, outcome) with or without a prospect, then **Link to prospect** later (search by name, company, phone or id; each result shows its stage; moving an already linked activity asks for confirmation). Activities are append-only: content and dates never change. |")
edit('README.md', "| **Relances** | Today / Overdue / Upcoming / Completed / Cancelled views (computed by the server), badges with counts, overdue rows highlighted, create / edit pending / complete (optionally recording the result as an activity) / cancel. |",
     "| **Relances** | Each relance has a type (call / appointment / message). Today / Overdue / Upcoming / Completed / Cancelled views (computed by the server), badges with counts, overdue rows highlighted, create / edit pending / complete / cancel. Completing can record the activity: the server creates it in the same transaction with the relance's type and prospect (never twice). |")
edit('README.md', "108 tests, no network needed.", "147 tests, no network needed.")
edit('README.md', "| Widget tests: lost-reason enforcement in the stage dialog, desktop shell + prospects table | `test/widgets/widgets_test.dart` |",
     "| Widget tests: lost-reason enforcement in the stage dialog, desktop shell + prospects table | `test/widgets/widgets_test.dart` |\n"
     "| Languages (ARB parity, plurals, RTL, runtime switch, persistence), shared prospect search, activity linking, profile fields saved as codes, themes | `test/widgets/enhancement_widgets_test.dart`, `test/core/localization_test.dart` |")
print('docs ok')
