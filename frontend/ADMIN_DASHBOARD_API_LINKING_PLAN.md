# Admin Dashboard — Full API Linking Plan

Audit of the Flutter admin feature (64 files) against every superuser-only endpoint in the Django Ninja backend, and a plan to close the remaining gaps.

Generated: July 2, 2026

---

## 0. Read this first: a real security gap, independent of everything else

While cataloging the backend's admin endpoints, four routes in `app_config/api.py` turned out to require only `AuthBearer()` (any logged-in user) instead of `SuperuserBearer()`, despite living under the `/admin/` path prefix and having proper superuser-gated equivalents elsewhere:

- `GET /admin/companies` and **`POST /admin/companies/{company_id}/status`** — the second one means **any authenticated user can currently change any company's approval status** by calling this endpoint directly, bypassing the app entirely. The Flutter app itself only calls the correctly-gated version in `companies/api.py`'s `admin_router`, so the app's own UI is safe — but the vulnerable duplicate endpoint is live on the server right now.
- `GET /admin/currencies`, `GET /admin/subscriptions` — lower severity (read-only data leak of currency/subscription-plan lists to any logged-in user), but still not intended.
- `GET /admin/config`, `GET /admin/countries`, `GET /admin/cities` are fully public (no auth at all) — likely intentional for public lookup data, but worth confirming since they sit in an "Admin API (Superuser Only)" tagged router.

**Recommendation: fix the `POST /admin/companies/{company_id}/status` auth requirement on the backend before anything else in this plan.** This is a backend-only change (swap `AuthBearer()` for `SuperuserBearer()` in `app_config/api.py`, and either delete the duplicate or confirm which of the two implementations is canonical), unrelated to Flutter linking work, and shouldn't wait on the rest of this plan.

---

## 1. What's already well-wired (the admin dashboard is the most mature area of the app)

Unlike the company dashboard, most of this is genuinely done: Feedbacks, App Configs, Companies list/status/details, Service Catalog, Service Types, Currencies, Global Categories, Subscription Plans, and notification Broadcast/Topic sending are all real, calling live endpoints, mostly with proper 12-item pagination and infinite scroll. Don't touch these.

---

## 2. Gaps — backend capability with no (or incomplete) Flutter UI

### 2.1 Notification targeting — Group and User, missing entirely
The backend has `POST /notification/send-group` (target a company, a post's followers, or an arbitrary list of user IDs) and `POST /notification/send-user` (target one specific user), both already implemented and superuser-gated. The Flutter `send_notification_screen.dart` only offers Broadcast and Topic — there's no `AppUrls` entry, no repository method, and no UI path for either. `NotificationRepository`'s interface only declares `getStatistics`, `sendBroadcastNotification`, `sendToTopic`.
**Plan**: add `sendToGroup(groupType, groupId, title, body)` and `sendToUser(userId, title, body)` to the repository/data source, add the two `AppUrls` entries, and extend the Target Type dropdown in `send_notification_screen.dart` with "Company", "Post Followers", and "Specific User" options (the group-type variants), plus a user-picker (reuse the existing Users list/search) for the specific-user case.

### 2.2 Products & Systems — read-only despite being labeled "manage"
`admin_module.dart` describes both modules as "Inspect and manage," but the screens only render lists — no create/edit/delete for products, no approve/reject action for systems (a `verificationStatus` badge is shown with nothing to act on it). The backend fully supports this: `POST/PUT/DELETE /admin/shop/products/{id}` (including reassigning `company_id`) and `PUT /admin/systems/{id}/status` (two independent `user_status`/`company_status` fields) both exist and are superuser-gated.
**Plan**: build an admin product edit/create form (mirroring the company-side product form, but with the added `company_id` reassignment field) and a system status-update action (two dropdowns for `user_status`/`company_status`, matching the two-field shape — don't build this as a single combined status control, the backend genuinely tracks them independently). Either relabel the modules honestly until built, or build the actions — recommend building, since both backend endpoints are ready and the mismatch between label and capability is the kind of thing that erodes trust once an admin notices.

### 2.3 Users — promote/demote only
The *backend* itself only supports `GET /users/` and `POST /users/promote/{username}` (which toggles `is_superuser` + `is_staff` together) — there is no ban/suspend/delete/edit endpoint anywhere in the backend. So this isn't a Flutter linking gap; the Flutter screen already matches everything the backend can do.
**Plan**: no Flutter work here. If ban/suspend/edit is wanted, it's a backend feature request first (new endpoints), not something to build against today's API.

### 2.4 Marketplace Oversight (Admin Offers/Requests) — fully built, but organizationally orphaned
This is the best-built admin list in the app (real pagination, infinite scroll, status filters, pull-refresh) — it's just in the wrong place. It lives in `features/offers/`, not `features/admin/`, and its only entry point is `admin_drawer.dart` pushing `/admin-marketplace` directly — it's completely absent from `admin_module.dart`'s module/dashboard-card list, so it doesn't show up as a normal admin dashboard tile.
**Plan**: add a proper module entry in `admin_module.dart` pointing at the existing screen (no new backend work needed — this is a pure navigation/information-architecture fix), and fix two real bugs found in it: the `onTap: () {}` no-ops on request/offer cards (tapping a row does nothing — should open a detail view), and the route registration issue described next.

---

## 3. Bugs to fix

1. **Dead route**: `admin_drawer.dart`'s "Service Requests" item and a notification deep-link both point at `/admin/service-requests`, which has no matching `GoRoute` anywhere — tapping it or receiving that notification type leads nowhere. Either register the route (if this was meant to point at something real — possibly the Service Catalog or the Marketplace Oversight screen) or remove the dead menu entry and deep-link mapping.
2. **Auth-guard bypass**: `/admin-marketplace` is registered outside the guarded admin `ShellRoute`, and doesn't match either `routeRequiresAdmin`'s check (`path == '/admin' || path.startsWith('/admin/')`). Any signed-in non-admin user can navigate directly to this URL and see the admin marketplace-oversight UI shell (the backend calls would still correctly 403, so no data leaks, but the UI itself shouldn't be reachable). Fix by moving it inside the guarded shell or widening the guard check to include it explicitly.
3. **Dead card taps**: `admin_offers_dashboard.dart` — tapping a request or offer card does nothing. Should open a detail view (the underlying data is already fetched).
4. **Mislabeled modules**: fix once 2.2 is built, or reword in the meantime.

---

## 4. Pagination/filtering standardization

Per the project's 12-item/infinite-scroll convention:
- **Companies list** uses `pageSize: 20` — bring it to 12 for consistency (cosmetic, backend already supports any page size via the `page_size` param).
- **Countries tab** (inside Address screen) fetch-all, no pagination, **no pull-to-refresh** — the only admin list missing pull-to-refresh entirely. Backend's `GET /admin/countries` doesn't paginate today either, so this is a minor/low-priority fix (country lists are inherently small), but the missing pull-to-refresh is a quick, worthwhile fix regardless.
- **Cities, Service Catalog, Service Types, App Configs**: all intentionally fetch-all against non-paginated or small-dataset endpoints — acceptable as-is, no action needed.
- **Admin Offers/Requests**: backend defaults to `page_size=10` (via a locally-rolled paginator), not the project's 12 — flag for a one-line backend fix (`page_size=10` → `page_size=12` default) for consistency, though the Flutter side likely already passes an explicit `page_size` and isn't affected.

---

## 5. Backend hygiene flags (independent of Flutter work)

- Section 0's auth-gating issues (highest priority — see above).
- `service_types_router`'s superuser-only CRUD lives at `/service-types/*`, entirely outside the `/admin/` namespace — confusing for anyone auditing "what's admin-only" by URL convention alone. Consider remounting under `/admin/service-types/` for consistency (would require a matching `AppUrls` + call-site update on the Flutter side, small and mechanical).
- `notifications/api.py` defines its own `SuperUserAuth` class instead of reusing `solar_hub.auth.SuperuserBearer` — functionally identical today, but a maintenance risk if the two ever drift.
- `systems` admin status update uses two independent fields (`user_status`, `company_status`) — not a bug, just make sure any new Flutter UI (see 2.2) matches this shape exactly rather than assuming one combined status.

---

## 6. Suggested order of work

1. **Backend security fix** (Section 0) — independent, do first, no Flutter dependency.
2. **Marketplace Oversight relink** (Section 2.4) — highest value for lowest effort; it's already built, just needs a module entry and two bug fixes.
3. **Dead route + auth-guard bypass** (Section 3, items 1–2) — quick, isolated fixes.
4. **Notification group/user targeting** (Section 2.1) — moderate effort, backend already supports it fully.
5. **Products/Systems admin actions** (Section 2.2) — the largest remaining item; build the product edit/create form and system status-update action.
6. **Pagination cleanup** (Section 4) — cosmetic, do whenever convenient.

---

*Methodology: two full-codebase passes — one cataloging every `SuperuserBearer`/`SuperUserAuth`-gated endpoint across `app_config`, `companies`, `shop`, `systems`, `offers`, `notifications`, and `users` apps (confirming `community` and `accounting` have none), one reading all 64 files under `lib/src/features/admin/` plus cross-referencing the `features/offers/` marketplace-oversight screen and the full "Admin" section of `app_urls.dart` against actual call sites. The auth-gating finding in Section 0 was surfaced directly while reading `app_config/api.py`'s endpoint decorators, not inferred.*
