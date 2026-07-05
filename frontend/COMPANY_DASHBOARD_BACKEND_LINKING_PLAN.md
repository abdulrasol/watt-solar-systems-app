# Company Dashboard — Backend Linking Plan

Full audit of the Flutter company dashboard against the Django Ninja backend, and a phased plan to link everything that isn't wired yet, with pagination and filtering brought up to the project standard (12 items/page, infinite scroll, real filter params — per `CLAUDE.md`).

Generated: July 2, 2026

---

## 1. What's already wired (don't touch)

Most of the "company side" of the app is genuinely well connected. These sections have real repositories calling real endpoints and don't need linking work: Overview summary (`companySummary`), Products/Inventory (own feature folder, paginated), Orders (own feature folder, paginated), Customers/Suppliers/CRM (own feature folder, proper query-object pagination), Members (invite/create/remove), Company Works/Portfolio, Accounting (ledger/accounts/invoices/bills/payments/journal/receivables/payables/transactions — the single most completely-wired backend domain in the app), Categories, Contacts, Public Services, Service Types, and the subscription/activation flow (plans, request, reminder).

The gaps fall into three buckets: **(A)** real backend capability with zero Flutter code pointing at it, **(B)** Flutter screens showing fabricated or misleading data instead of a real call, and **(C)** wired screens that fetch-all instead of paginating/filtering. Below is the full breakdown, then a phased plan to close all three.

---

## 2. Bucket A — backend capability with no Flutter code at all

| Backend endpoint | What it does | Current Flutter state |
|---|---|---|
| `GET/POST /companies/{id}/delivery`, `DELETE .../delivery/{id}` | Delivery options CRUD, already paginated (`page_size=12`) server-side | No screen, no menu entry, no repository method. `AppUrls.deliveryOptions`/`deleteDeliveryOption` are defined but never called. |
| `GET/POST /companies/{id}/expense`, `DELETE .../expense/{id}` | Expense tracking, paginated server-side | Same — fully dead on the Flutter side. |
| `GET /companies/{id}/systems` | Installed systems belonging to the company | No screen. `AppUrls.companySystems` never called. |
| `GET /companies/{id}/analytics` | Server-computed dashboard counters (products, orders, expenses, transactions) in one call | No screen calls it. The app instead reconstructs similar numbers by calling 3+ separate accounting/inventory endpoints from the Overview screen — more round-trips than necessary. |
| `GET /companies/{id}/services` | Company's service catalog status | Never called — the app derives "which services are active" purely from the `summary` payload instead. Low priority; summary already covers this. |

Additionally, `company_workspace_modules.dart`'s `fromService()` mapping (the function that turns a backend service code into a sidebar menu item) only recognizes `offers`, `inventory`, `company_work`, `multi_member`, `accounting`, `analytics`, `storefront_b2b`, `storefront_b2c`. Any backend service coded `delivery`, `expenses`, `finance`, or `systems` returns `null` and **is silently dropped from the menu** — even if a company has that service activated on the backend, no UI ever appears for it. This is the root cause of buckets A above: the menu can't route to a screen that both doesn't exist and wouldn't be shown even if it did.

**Not a gap — false positive to avoid building against:** `AppUrls.companyOfferRequests`/`companyOffers`/`createOfferReply` (the `/companies/{id}/offers/...` group) look unwired, but they're a **duplicate** backend surface for the same feature the app's `offers` module already correctly uses via the global `/offers/...` group (`requestsBaseUrl`, `availableRequests`, `myOffers`, `replyToRequest`). Confirmed by reading both implementations: `/companies/{id}/offers/requests` just returns `OfferRequest.objects.all()` filtered by status — the same data as the global endpoint, not company-scoped in any meaningful way. Don't build UI against this group; remove the dead `AppUrls` entries instead (see Phase 4).

**Backend dead code, not a Flutter gap:** `companies/api.py` defines a second `commerce_router` (lines ~1578-1648) with its own `customers`/`suppliers`/`orders` endpoints — but it's never imported into `solar_hub/api.py`, so it's unreachable at runtime. The live implementation is `shop/commerce_api.py`'s `company_router`, which the Flutter CRM/Orders features already use correctly. Flag for backend cleanup (Phase 4); no Flutter action needed.

---

## 3. Bucket B — screens showing fake/misleading data instead of a real call

1. **"Recent Activity" on the Overview screen** (`presentation/providers/company_activity_provider.dart`) doesn't call `companyActivity(id)` at all — it stitches together the last few items from the inventory, offers, and notification providers client-side, with hardcoded English titles like `'New product added'`. It looks like a real activity feed but isn't one.
2. **Order distribution pie chart** (`presentation/widgets/order_distribution_chart.dart`) falls back to **hardcoded values `40`, `30`, `15`** when the accounting overview hasn't loaded or is null — so a brand-new company with zero real orders sees a populated-looking chart with fake numbers and no indication it's a placeholder.
3. **Dead buttons**: "Restock" and "View all alerts" on the low-stock-alerts card (`overview_content.dart`) have empty `onPressed: () {}` — they look tappable but do nothing.
4. **Support contact placeholder**: `construction_page.dart`'s (`ServiceStatusPage`) contact-support sheet has list tiles that just close the sheet with no real action behind them.

---

## 4. Bucket C — wired but not paginated/filtered (CLAUDE.md violation)

The project convention is 12 items/page with scroll-triggered infinite loading. Inventory, Orders, CRM (customers/suppliers), and Offers already do this correctly via query-object + `PaginatedItemsResponse` patterns. The screens owned directly by `company_dashboard` do not:

| Screen | Backend supports pagination? | Flutter passes params? | Scroll behavior |
|---|---|---|---|
| Categories | No — endpoint has no page/search params at all | No | Non-scrollable `Wrap`, fetch-all |
| Contacts | Yes (`page`, `page_size=12`) | Only `page: 1`, `pageSize` never set | `ListView.builder` with `NeverScrollableScrollPhysics` — no load-more |
| Public Services | No — fetch-all endpoint | No | Non-scrollable, fetch-all |
| Service Types | No — fetch-all endpoint (and it's the *global* list, not company-scoped) | No | fetch-all |

Categories, public services, and service-type lists are typically short (tens of items), so fetch-all hasn't caused visible problems yet — but it's inconsistent with the rest of the app and will degrade for companies with large catalogs. Contacts already has backend pagination sitting unused.

---

## 5. Phased plan

### Phase 1 — Fix what's actively misleading (do first, no new endpoints needed)
- Remove the hardcoded `40/30/15` fallback in `order_distribution_chart.dart`; show an explicit empty/zero state instead when `overview` is null.
- Either relabel "Recent Activity" honestly (e.g. "Recent updates across your workspace") since it's a client-side aggregation, or replace it with a real call to `companyActivity(id)` if that endpoint returns genuinely richer data than the three providers already fetch (needs a quick look at what the backend `activity` endpoint actually returns — not yet confirmed in this audit; recommend checking before choosing which path).
- Wire the "Restock" and "View all alerts" buttons to real navigation (restock → the relevant inventory product's edit screen; view-all-alerts → a filtered inventory list of low-stock items).
- Implement or remove the support-contact sheet's placeholder actions.

### Phase 2 — Close Bucket A (new sections against real, already-built backend endpoints)
For each of Delivery, Expenses, Systems:
1. Add the missing service codes (`delivery`, `expenses`, `systems`) to `company_workspace_modules.dart`'s `fromService()` switch and `company_dashboard.dart`'s `_getNavItems` switch so the menu entry appears when the backend reports the service as active.
2. Build repository + controller + paginated list screen for each, following the same structure as the existing Contacts feature (which already has the right shape, just needs its own pagination turned on — see Phase 3).
3. For **Finance** specifically: don't build UI against `/companies/{id}/finance` (the `FinancialTransaction` model) yet. It looks like a legacy parallel ledger sitting alongside the newer, more complete `accounting` app (Invoice/Bill/Payment/JournalEntry) that's already fully wired. Confirm with whoever owns the backend whether `FinancialTransaction`/`Expense` are meant to be superseded by `accounting`'s models before investing in a screen — building against a model that's about to be deprecated would be wasted work. (Expense is a bit different — it's a standalone company-level cost record, not obviously replaced by accounting's bill/invoice model — likely safe to build directly, but confirm the relationship between `Expense` and `accounting.JournalEntry` first, since `Expense` already carries an optional link to one.)
4. Add an Analytics screen (or fold `analytics(id)`'s numbers into the Overview) to replace the current multi-endpoint reconstruction with the single purpose-built call — fewer round trips, one source of truth for the dashboard counters.

### Phase 3 — Standardize pagination & filtering (Bucket C)
Bring Categories, Contacts, Public Services, and Service Types up to the pattern already proven in Inventory/CRM/Offers:
- **Contacts**: lowest effort — backend already paginates. Add a `ContactQuery` (page, pageSize=12, search) mirroring `CustomerQuery`, wire `ListView.builder` with a scroll-controller triggering `fetchContacts(page: next)` when near the bottom, and actually pass `pageSize`.
- **Categories & Public Services**: need backend work first — add `page`/`page_size`/`search` query params to `GET /companies/{id}/categories` and `GET /companies/{id}/public-services` (mirror the existing `page_size=12` pagination already used on Delivery/Expense/Contacts in the same file), then repeat the Contacts pattern on the Flutter side.
- **Service Types**: this one's currently hitting the *global* service-types list, not anything company-scoped, so "filtering" here means adding a search/category filter to the existing public list rather than adding company scoping — lower priority, cosmetic improvement only.

### Phase 4 — Cleanup (both sides)
- Remove dead `AppUrls` entries once confirmed genuinely unneeded: `companyServices`, `companyOfferRequests`, `companyOffers`, `createOfferReply` (duplicate marketplace surface — see Bucket A note), and consolidate `productDetails`/`deleteProduct` so inventory's data source calls the helper methods instead of hand-building the same URL string.
- Flag for backend cleanup: delete the unreachable `commerce_router` in `companies/api.py` (dead code, never mounted, duplicates `shop/commerce_api.py`).
- Flag for backend cleanup: `notifications/api.py` uses its own `BearerAuth`/`SuperUserAuth` (manual JWT decode) instead of the `solar_hub.auth.AuthBearer`/`SuperuserBearer` used everywhere else — not a Flutter-side problem, but worth a consistency pass since it's the one auth mechanism in the whole API that doesn't match the rest.

### Phase 5 — Out of scope for "company dashboard" but worth knowing about
The backend `community` app (`/community/`) — a lightweight posts/comments social feed, optionally attributable to a company — has **no Flutter feature at all**, wired or not. It's not part of the company dashboard conceptually (it reads more like a general app-wide feed), so it's excluded from this plan, but it's the single largest fully-unbuilt backend surface in the app if a future "community/feed" feature is ever prioritized. Worth noting it also has its own gaps on the backend side (no like/unlike endpoint despite a `likes_count` field, no image-upload endpoint despite an `image` field on the model, and a stale `Reply` schema referencing a deleted model) — so it isn't even fully backend-ready today.

---

## 6. Suggested order of work

1. Phase 1 (half a day — no backend changes, just removing fake data and dead buttons).
2. Phase 3's Contacts pagination (backend already supports it — fastest real win, and it's the reference pattern for everything else).
3. Phase 2's Delivery + Expenses + Systems screens (each is a fairly mechanical repeat of the Contacts shape once Contacts is the reference implementation) + menu-mapping fix.
4. Phase 3's backend pagination additions for Categories/Public Services, then their Flutter screens.
5. Phase 2's Analytics screen / Overview consolidation.
6. Phase 4 cleanup pass.

---

*Methodology: two full-codebase passes — one cataloging every company-relevant Django Ninja endpoint across `companies`, `shop`, `accounting`, `systems`, `community`, and `notifications` apps (paths, auth, pagination/filter params), one cross-referencing every `AppUrls` company-related method against actual call sites in `lib/src/features/`. Findings on the duplicate offers surface and the unmounted `commerce_router` were independently verified by reading the router mount list in `solar_hub/api.py` directly.*
