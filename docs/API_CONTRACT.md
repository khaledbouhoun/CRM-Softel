# SOFTEL CRM — API contract used by the Flutter client

> **Status: aligned with the Laravel backend (2026-11-02).**
> The authoritative contract is the backend's
> `Laravel Backend/docs/API.md`. This file only records how the client maps
> that contract onto its models, and the few client-side behaviours that the
> API does not provide directly. If the two documents disagree, the backend
> document wins and the client must be fixed.

Where things live in the client:

| What | Where |
|---|---|
| URL paths | `lib/core/network/api_endpoints.dart` + data sources |
| Response field names | `fromJson` of the models in `features/*/data/models` |
| Payload field names | `toJson` of the request / payload models |
| Query parameters | `toQuery()` of the filter models, `FollowUpView.toQuery()` |
| Envelope / pagination | `lib/core/network/api_response.dart` |
| Errors | `lib/core/network/api_exceptions.dart` |

## 1. Conventions

- Base URL: `http://SERVER_IP:PORT/api/v1`, configured in the app settings.
- Envelope: `{ success, message, data, meta }`; errors
  `{ success: false, message, error_code, errors }`.
- Connection test: `GET /health` (answers 503 when the database is down).
- Dates: the client sends ISO 8601 with the local offset
  (`2026-11-01T14:30:00+01:00`) and plain dates as `YYYY-MM-DD`. The server
  answers in its business timezone with offset.
- 422 with `error_code: VALIDATION_FAILED` is shown as
  « Certaines données sont invalides. » plus the field messages. Field messages
  are displayed next to the matching input; **messages for fields the form
  does not show are appended to the form's error text** (never hidden).
  Other 422 codes (`INVALID_STAGE_TRANSITION`, `INVALID_FOLLOW_UP_STATE`,
  `STAGE_TYPE_LOCKED`, `LAST_OPEN_STAGE`) show the server message.

## 2. Field mapping

| Client model . field | API field |
|---|---|
| `Prospect.companyName` | `name` |
| `Prospect.contactName` | `contact_person` |
| `Prospect.lossDetails` | `loss_note` |
| `Prospect.lastActivityAt` / `nextFollowUpAt` | `last_activity_at` / `next_follow_up_at` |
| `ProspectRef` | `ProspectSummary` (`id`, `name`, `contact_person`, `phone`, `is_deleted`) |
| `SalesStage.type` / `position` | `stage_type` / `sort_order` |
| `SalesStage.isUsed` | derived: `prospects_count > 0` (unknown → used) |
| `LossReason.label` / `requiresDetails` / `position` | `name` / `requires_note` / `sort_order` |
| `Activity.occurredAt` | `activity_at` |
| `FollowUp.dueAt` | `scheduled_at` |
| `FollowUp.description` | `description`, or `title` when there is no description |
| `FollowUp.closingNote` | `closing_note` (completion result or cancellation reason) |
| `FollowUp.isOverdue()` | `due_state == 'overdue'` |
| `StageHistoryEntry.lossDetails` | `loss_note` |
| `DashboardSummary.totalProspects` … | `prospects.total` / `.open` / `.won` / `.lost` |
| `DashboardSummary.stages` | `prospects_by_stage[]` (`sales_stage_id`, `count`, …) |
| `DashboardSummary.lostByReason` | `lost_by_reason[]` (`loss_reason_id`, `name`, `count`) |

## 3. Endpoints used

| Feature | Request |
|---|---|
| Prospects list | `GET /prospects?search&sales_stage_id&product_id&loss_reason_id&created_from&created_to&sort&direction&page&per_page` |
| Prospect create / update | `POST /prospects`, `PUT /prospects/{id}` (`name`, `contact_person`, …, `product_ids`; `sales_stage_id` on create only) |
| Products of a prospect | `PUT /prospects/{id}` with only `product_ids` |
| Stage change | `POST /prospects/{id}/change-stage` (`sales_stage_id`, `loss_reason_id`, `loss_note`) → `{ prospect, stage_history }` |
| Stage history | `GET /prospects/{id}/stage-history?per_page=100` |
| Activities | `GET /activities?prospect_id&type&date_from&date_to&search`, `POST /prospects/{id}/activities` |
| Follow-ups (tabs) | `GET /follow-ups?scope=today\|overdue\|upcoming`, `?status=completed&sort=completed_at&direction=desc`, `?status=cancelled` |
| Follow-ups of a prospect | `GET /prospects/{id}/follow-ups`, `POST /prospects/{id}/follow-ups` |
| Follow-up edit / close | `PUT /follow-ups/{id}`, `POST /follow-ups/{id}/complete`, `POST /follow-ups/{id}/cancel` (`closing_note`) |
| Reference data | `GET /sales-stages`, `/loss-reasons`, `/products` (all entries; `?is_active=1` for active only) |
| Configuration | `POST`/`PUT`/`PATCH`/`DELETE` on `/products`, `/sales-stages`, `/loss-reasons`; `POST …/reorder` with `{ "ids": [...] }` |
| Dashboard | `GET /dashboard` |

## 4. Client-side behaviours

- **Follow-up text.** The form edits one text. Short single-line texts
  (≤ 200 characters) are sent as `title`; longer texts are sent in full as
  `description`, with their first line (cut to 200 characters) as `title`.
- **Completing a follow-up with a result.** Two requests: first
  `POST /follow-ups/{id}/complete` with the result as `closing_note`, then
  `POST /prospects/{id}/activities`. If the second request fails the follow-up
  stays completed, the result remains in its closing note, and the user is told
  to add the activity from the prospect page.
- **Activity + next follow-up.** The activity form saves the activity, then
  creates the follow-up (`POST /prospects/{id}/follow-ups`); a failure of the
  second step is reported separately.
- **Sorting.** The API sorts prospects by `name`, `city`, `created_at` and
  `updated_at` only; the stage, last-activity and next-follow-up columns are
  not sortable. The pipeline orders cards by `updated_at` (most recent first).
- **Overdue** means scheduled before today (whole days in the server's
  timezone), as computed by the server.
- **Dashboard « Relances à venir »** counts the next `upcoming_window_days`
  days only; the « À venir » list shows every upcoming follow-up.
- **Not available in the API** (removed from the client): a free comment on a
  stage change, the "lost on" date of a prospect (visible in the stage
  history instead), the "next follow-up" stored on an activity.
