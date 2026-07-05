# Solar Hub — Full Codebase Analysis
Flutter app · ~104,700 LOC · 539 Dart files in `lib/src` · Riverpod + GetIt + go_router + Firebase + Dio
Generated: July 2, 2026

---

## 1. Overview

Solar Hub is a mid-to-large Flutter app (solar system design/calculation, B2B marketplace, admin, CRM, accounting) organized as ~20 feature modules under `lib/src/features/*`, each following a `data/domain/presentation` clean-architecture split. State management is `flutter_riverpod` 3.x, DI is `get_it`, routing is `go_router`, persistence is a mix of `get_storage` (KV cache), `sqflite_common_ffi` (declared but effectively unused), and `cloud_firestore` (cloud sync), with `dio` for REST calls to a Python backend.

The architecture is fundamentally sound — Riverpod adoption is consistent (~88% of stateful screens), layering is mostly respected, and there's no widespread anti-pattern chaos. The problems are concentrated: one critical memory leak, one critical performance hotspot, one high-severity security gap, and a long tail of medium/low issues from rapid, unreviewed feature growth (typo'd folders, duplicated painters, inconsistent error handling).

---

## 2. Memory Leaks

### Critical
**`panel_placement_step.dart:130,141`** — a new `TextEditingController` is instantiated inline inside `build()` on every rebuild:
```dart
controller: TextEditingController(text: state.horizontalGapM.toStringAsFixed(3)),
controller: TextEditingController(text: state.verticalGapM.toStringAsFixed(3)),
```
Since `onChanged` triggers a state update which triggers a rebuild, **every keystroke leaks the previous controller instance** (never disposed — `PvNumberField` treats it as externally owned). This is the single worst leak in the app because it compounds continuously during normal use of the panel-placement wizard step, not just once per screen visit.
*Fix*: hoist controllers into State fields (create once, sync via listener/`didUpdateWidget`), dispose in `dispose()`.

### High
Three screens have `TextEditingController` fields with **no `dispose()` override at all** in the class:
- `calculations/presentation/screens/battery_calculator/count_calculator.dart:25-29` (4 controllers)
- `calculations/presentation/screens/battery_calculator/time_calculator.dart:26-29` (4 controllers)
- `auth/presentation/screens/company_registration_page.dart:33-36,53` (4 controllers + a `ValueNotifier<File?>`)

### Medium — systemic, design-level
Riverpod provider retention: only **1 provider in the entire codebase uses `.autoDispose`** out of 152 provider declarations across 66 files. Screen-scoped state (inventory filters, product-add forms, storefront filters, the calculator's `ChangeNotifierProvider` with its internal Timer) is retained in the container for the app's full lifetime once touched, even after the owning screen is popped. Not a bug per se, but an unbounded memory floor that grows the longer a session runs across many screens.

### Low
- Locally-scoped, short-lived `TextEditingController`s inside dialog builders (`export_step.dart:57`, `visual_grid_canvas.dart:413`, `involves_catalog_screen.dart:234-235`) aren't disposed — minor, GC-eligible on dialog close, but still worth fixing.
- `push_notification_service.dart` has a `dispose()` that cancels 3 subscriptions but is never called (the service is a permanent singleton) — dead code, not a real leak.
- `carousel_slider` is a declared dependency but is unused anywhere in `lib/` — dead weight, not a leak.

### Clean / verified no issues
Timers (all cancelled correctly), most `StreamSubscription`s (notification polling, compass, storefront debounce — all properly cancelled in `dispose()`/`ref.onDispose()`), `addListener`/`removeListener` pairing, GetIt singleton design (no captured `BuildContext`), and `Geolocator` usage (one-shot calls only, no leaked position streams).

---

## 3. Performance

### Critical — systemic in one feature
Every screen and widget in **`pv_system_designer`** (10 files) calls `ref.watch(pvSystemDesignerProvider)` on the *entire* monolithic state object instead of using `.select(...)` for narrow slices. `roof_grid_canvas.dart:19` is the worst case: a potentially large `GridView` rebuilds completely whenever *any* field changes — including unrelated undo/redo stack pushes on every cell tap. `structure_design` (the sibling feature) does this correctly — only the screen shell watches the controller, and result widgets receive data via constructor params.
*Fix*: `ref.watch(pvSystemDesignerProvider.select((s) => (s.grid, s.rows, s.cols)))` per widget, scoped to what each widget actually reads.

### High
`CachedNetworkImage` is used consistently (good — only one stray `Image.network`), but `memCacheWidth`/`memCacheHeight` is set in only 2 of 19 files using it. Product galleries, company logos, and gallery thumbnails decode full-resolution images at thumbnail display size — real memory/CPU cost at scale, especially in scrolling grids.

### Medium
- Custom-painter geometry in `technical_structure_sketch_painter.dart` (1,427 lines) recomputes layout on every `paint()` call with no memoization, even for pure pan/zoom — `shouldRepaint` itself is implemented correctly (field-equality, not `=> true`), but the paint body is expensive.
- Top-level `setState(() {})` (whole-widget rebuild) in wizard/calculator screens: `structure_design_screen.dart:121`, `fast_calculator.dart` (4 call sites), `storefront_products_screen.dart`, `storefront_filters_sheet.dart`, `add_member_sheet.dart` — none catastrophic individually, but each rebuilds a whole form on every keystroke/toggle rather than isolating the changed subtree.
- Eager `ListView(children: [...map()])` in `storefront_cart_screen.dart:61-64,157` instead of `.builder` — low impact given typical cart sizes, but inconsistent with the rest of the app's otherwise-correct lazy-list discipline (45 files correctly use `.builder`/`.separated`).

### Low
Missing `const` constructors is a widespread minor pattern (not a hotspot on its own); a redundant second `ScreenUtilInit` wrapper in `splash_screen.dart:194` re-runs init config with no benefit.

### No issues found
No direct Firestore `.snapshots()` listeners anywhere (all remote data goes through Dio/repositories, so the "resubscribe on rebuild" anti-pattern doesn't apply); app startup (`main.dart`) awaits only Firebase/GetStorage/DI init before first frame, and splash defers heavier work via `unawaited()` — good pattern.

---

## 4. Architecture & Structure

**Layering**: ~90% consistent (domain doesn't depend on data/presentation in most features), but two concrete violations exist: `calculations/domain/entities/calculated_system.dart` imports a presentation-layer Riverpod controller directly, and `admin_systems_controller.dart`/`admin_products_controller.dart` bypass the repository interface to call the data source directly. No architecture test/lint enforces the boundary, so these will keep recurring.

**Dependency injection**: `core/di/get_it.dart` is a single 322-line flat file (not modularized per feature), 44 registrations, all `registerLazySingleton` with no differentiation for stateless/per-call use cases. More concerning: `getIt<...>()` is called directly from **widgets**, not just providers, in at least 6 places (`accounting_screen.dart:207`, `drawer.dart:311`, `password_reset_page.dart`, `profile_page.dart`, `delete_account_sheet.dart`, `splash_screen.dart`, `role_selection_page.dart`) — bypassing Riverpod's provider graph and testability entirely for those call sites.

**State management**: healthy — Riverpod is the dominant paradigm (134 Consumer-based files vs. 18 plain `StatefulWidget`, 144 `StatelessWidget`). No mixed-paradigm chaos.

**Routing**: a single 614-line `app_routers.dart` defines ~100 routes in one `GoRouter` provider. Guard logic (`routeRequiresAdmin`, `routeRequiresCompanyMember`, `routeRequiresAuthenticatedUser`) is clean and centralized, but the monolithic file is a merge-conflict/maintainability risk as the route count grows.

**Error handling — genuine inconsistency**: two incompatible contracts coexist. `Either<Failure, T>` (dartz) is used in only 13 files across 4 features (offers, splash, admin/notification, company_dashboard); the remaining ~15+ repositories (inventory, storefront, crm, accounting, members, auth) throw raw exceptions with no wrapping — e.g., `inventory_repository_impl.dart` has no try/catch at all, letting Dio exceptions propagate unhandled. There's no house rule for which pattern a new repository should follow.

**Duplication**: 
- Drawing/canvas logic is duplicated across 5-6 separate `CustomPainter` classes with no shared base — `structure_design` alone has *three* overlapping painters (structure/technical/enhanced sketch, 1090/1427/831 lines), strongly suggesting iterative rewrites that never removed the old versions.
- `orders_company` has no data layer of its own — it imports `orders_buyer`'s providers directly, an odd coupling that will confuse future maintainers even though it avoids literal code duplication.

**Naming hygiene**: four typo'd directories are now baked into imports app-wide: `core/cashe/` (cache), `settings/domain/entiteis/` (entities), `feedback/data/data_sourece/` (data_source), `shared/presntations/` (presentations). Harmless functionally, but signals no naming review/lint gate exists.

**File size outliers**: several 800-1400 line files, including three duplicate sketch painters and "god widgets" like `admin_feedbacks_screen.dart` (1,000 lines) and `offer_reply_form.dart` (940 lines) — likely mixing layout, validation, and business logic in one build method.

**Testing**: 15 test files against 539 lib files. Coverage clusters around a few recently-built features (structure_design, admin, services, splash); entire feature areas — inventory, storefront, all three order modules, CRM, accounting, offers, feedback, members — have zero tests.

---

## 5. Security

### High
**Auth token and full user profile stored unencrypted** — `core/cashe/get_storage_cashe.dart:57-75`, `saveToken()`/`token()` write the bearer token via plain `GetStorage`, which persists as an unencrypted JSON file on disk (readable on rooted/jailbroken devices or from backups). The same store also holds the full `User` object. *Fix*: move token/user storage to `flutter_secure_storage` (Keychain/Keystore-backed); keep GetStorage for non-sensitive cache (saved designs, UI flags — appropriate as-is).

### Medium
- **Hardcoded static AES-256 key** in `pv_system_designer/data/drawing/watt_drawing_file_service.dart:56-61` used to "encrypt" exported `.wattd` drawing files. Since the key ships in the client binary, this is encryption theater — anyone can decompile and decrypt. Low real-world impact (protects design/BOM data, not credentials) but misleading if users assume real confidentiality.
- **No Firestore/Storage security rules found in the repo** — can't be assessed from client code; must be verified directly in the Firebase console, since misconfigured/default-open rules are a common critical vulnerability invisible from the app side.
- **`simple_step_checkout`** dependency is pulled from a personal GitHub fork, not pub.dev — unvetted supply-chain risk (no lockfile guarantee beyond a git ref).
- **No TLS certificate pinning** — standard for many apps, but this one handles auth tokens and B2B financial/accounting data, so pinning would meaningfully raise the MITM bar.
- **No R8/ProGuard minification** configured for Android release builds (`android/app/build.gradle.kts:68-76`) — ships unobfuscated plugin code, larger binary.

### Low
- Verbose Dio request/response logging (`core/services/dio.dart`) includes auth context and full bodies — confirm it's stripped/no-op in release builds.
- Release signing silently falls back to debug signing if the hardcoded external `key.properties` path is missing, rather than failing loudly.
- `dartz` and `barcode_scan2` carry general maintenance risk (aging/low-activity packages).
- FCM push permission is requested at app startup with no in-app rationale UI first (UX concern, not a vulnerability).

### Clean / good practice
No hardcoded API keys/secrets in source; `google-services.json`/`GoogleService-Info.plist`/`firebase_options.dart` are properly `.gitignore`d; location and camera permissions are requested lazily at point-of-use with proper denied/deniedForever handling, not upfront; no production cleartext HTTP traffic (dev-only URLs are gated behind `kReleaseMode`).

---

## 6. Priority Action List

1. **Fix now** — `panel_placement_step.dart` controller-per-rebuild leak (compounding memory leak on every keystroke).
2. **Fix now** — move auth token/user storage from `GetStorage` to `flutter_secure_storage`.
3. **This sprint** — add `.select()` scoping to `pv_system_designer`'s 10 `ref.watch` call sites, especially `roof_grid_canvas.dart`.
4. **This sprint** — add `dispose()` to the 3 controller-leaking screens (`count_calculator`, `time_calculator`, `company_registration_page`).
5. **Soon** — verify Firestore/Storage security rules in the Firebase console directly (not assessable from code).
6. **Soon** — pick one error-handling contract (`Either<Failure, T>` vs. exceptions) and migrate repositories consistently; enable R8/ProGuard for release builds.
7. **Backlog** — add `memCacheWidth/Height` to remaining `CachedNetworkImage` call sites; consolidate the three duplicate sketch painters in `structure_design`; consider `.autoDispose` for screen-scoped Riverpod providers; expand test coverage to untested feature areas (inventory, storefront, orders, CRM, accounting).

---

*Methodology: static analysis via targeted grep/read passes across `lib/src` (539 files, ~104.7K LOC), cross-checked with direct file reads for the highest-severity claims. This is a code-level review, not a runtime profile — recommend following up with the Flutter DevTools memory/performance profiler on the flagged screens (panel placement step, roof grid canvas) to confirm real-world magnitude before prioritizing engineering time.*
