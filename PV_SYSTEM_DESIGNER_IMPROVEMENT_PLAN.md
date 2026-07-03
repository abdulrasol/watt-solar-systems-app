# PV System Designer — Improvement Plan (Path to a Real, End-User-Ready PVsyst-style Tool)

Feature: `lib/src/features/pv_system_designer` · ~5,090 LOC across 30 files
Generated: July 2, 2026

---

## 1. What this feature actually is today

It's a well-structured *layout and structural-BOM* wizard — pick a site, sketch a roof, place panels on a grid, size the mounting frame, get a bill of materials and a technical drawing. The 7-step wizard, undo/redo on the grid, pinch-zoom canvas, and the structural steel-frame calculator (row spacing, leg heights, rail/brace lengths — `structure_design_calculator.dart`) are genuinely solid engineering and good UX scaffolding.

But the part that should be the product's core value — **simulating how much energy the system will actually produce** — is not real yet. That's the gap between "layout tool" and "PVsyst-style design tool," and it's where effort should concentrate first.

---

## 2. Reality check: what's simulated vs. what's placeholder

This is the most important finding, so it's stated plainly before anything else:

| Piece | What it looks like to the user | What it actually does |
|---|---|---|
| Weather/irradiance data | `OpenMeteoSolarDataSource.fetchSolarData()` — named after a real weather API | **Never calls any API.** It's a stub (`// TODO: Integrate with http package or dio for actual API calls`) that always falls back to a hardcoded 5-bucket latitude lookup table (e.g. "lat 30-45° → 4.5 peak sun hours"), the same number for Baghdad, Cairo, or Madrid. |
| Energy production estimate | Daily/monthly/annual kWh, capacity factor, CO₂ offset on the Results screen | `dailyKwh = peakPowerKwp × peakSunHours × performanceRatio` — a single flat multiplication. No transposition of irradiance onto the actual tilt/azimuth, no temperature effect, no inverter model, no monthly/seasonal irradiance variation beyond a fixed synthetic sine-like curve applied to every location on Earth at the same latitude band. |
| Shading simulation | A time-of-day slider (Sunrise/Noon/Sunset) that recolors shaded panels | `shadowMultiplier()` is `0.5 + (|hour-12| / 4.5) × 2.0` — an arbitrary formula with no relationship to the sun's actual elevation/azimuth for that latitude, longitude, or date. There's no date input at all, so there's no way to check winter vs. summer shading, which is the entire point of shading analysis in a real tool. |
| System losses | A single "System Losses %" input, default 14% | Not a loss *diagram* — no breakdown into soiling, mismatch, DC/AC wiring, inverter efficiency, availability, or degradation. Just one number the user has to guess. |
| Inverter/string sizing | Not present at all | No inverter entity, no MPPT voltage window check, no Voc-at-cold-temperature compliance check, no string current vs. breaker/fuse rating. A layout can be produced that is electrically invalid and the tool would never warn the user. |
| PDF export | "Full View" → PDF icon in the technical sketch viewer | Shows a SnackBar "Coming soon: PDF Export." Not implemented. |
| "Share & Request Quotes" | Button on the Export step | Shows a fake success toast ("Your proposal has been shared with suppliers"). No network call, no backend integration — it does nothing. |
| Financial/ROI | Not present at all | No cost input, no payback period, no ROI — for a tool meant to help a customer decide to buy a system, this is normally the first thing they ask about. |

None of this is a criticism of the work done — the structural/geometry side is genuinely good — but as it stands the "energy simulation" is decorative. If this ships to end users who compare it against PVsyst, PVWatts, or even a solar installer's quote, the production numbers will be visibly wrong (often by 20-40%, since it ignores tilt/azimuth losses, temperature, and real local climate).

---

## 3. Calculation & simulation upgrade plan (the core of "improve simulation and calculation")

### 3.1 Replace the fake weather stub with a real free irradiance API
Two free, no-signup, generous-limit options were confirmed as viable for this app:

- **Open-Meteo** (already the class's namesake, just never wired up) — its forecast/archive API directly supports `global_tilted_irradiance` for an arbitrary panel tilt/azimuth, plus GHI/DNI/DHI and temperature, at any lat/lon, hourly or daily, no API key required. This is the most direct fix — implement the actual HTTP call in `OpenMeteoSolarDataSource.fetchSolarData()` (the TODO already marks the exact spot).
- **PVGIS** (EU Joint Research Centre, `re.jrc.ec.europa.eu/api/v5_3/PVcalc`) — goes further: given `peakpower`, `loss`, `angle` (tilt), `azimuth`, and location, it returns full monthly/hourly PV *yield* output directly, using its own validated irradiance database and horizon-shading model, worldwide (though its historical satellite coverage is strongest for Europe/Africa/Asia — worth validating accuracy for the app's actual user base location).

Recommendation: use Open-Meteo for live irradiance input into your own calculation engine (keeps you in control of the model, works everywhere), and optionally offer PVGIS as a secondary "validate against PVGIS" cross-check for credibility.

### 3.2 Add a real solar-position model to replace the `simulationTime` slider
The shading step needs an actual sun-position algorithm (solar declination + hour angle → elevation & azimuth) driven by **date + time + latitude + longitude**, not an arbitrary parabola. This is a well-known, compact, dependency-free formula (NOAA/Cooper's equation for declination, standard hour-angle formula for elevation/azimuth) — a few dozen lines of pure math, no external package needed. With this in place:
- The shading step gains a **date picker** (or at minimum solstice/equinox presets: Jun 21, Dec 21, Mar/Sep 21) so users can check worst-case winter shading, which is the actual purpose of shading analysis.
- `shadingSourceCell()` in `shadow_calculator.dart` can compute real shadow length/direction from wall and obstacle heights using actual sun elevation/azimuth, instead of the current fixed north/south/east/west adjacency heuristic — this turns it from "decorative shading colors" into an actual shading study.
- The existing row-spacing formula in `structure_design_calculator.dart` (`_rowSpacing`, using a winter-elevation approximation with a hardcoded 23.5° declination) can be replaced with the same real solar-position function for consistency and precision, gaining accuracy for extreme latitudes and non-Dec-21 module tilts.

### 3.3 Fix the energy model: transposition, temperature, and a real loss diagram
Replace `EnergyEstimator.estimate()`'s single multiplication with a proper chain:
1. **Plane-of-array irradiance**: transpose GHI/DNI/DHI onto the actual tilt/azimuth from step 3.1's data (a simplified isotropic-sky or Hay-Davies transposition model is enough — doesn't need PVsyst's full Perez model to be a large accuracy jump over "flat PSH regardless of orientation").
2. **Temperature derating**: apply the panel's temperature coefficient (typically ~ -0.35%/°C for silicon) against cell temperature estimated from ambient temp + irradiance (simple NOCT model: `Tcell = Tamb + (NOCT-20)/800 × G`). Right now tilt, azimuth, and climate temperature have **zero effect** on the kWh number shown to the user — this is the single highest-leverage fix for credibility.
3. **Loss diagram** instead of one flat percentage: soiling (~2%), mismatch (~2%), DC wiring (~1.5%), AC wiring (~1%), inverter efficiency (~97-98%, ideally from an efficiency curve not a flat number), availability (~99%), and first-year + annual degradation (~0.5%/yr) as separate, user-adjustable factors with sensible defaults — mirrors how PVsyst/PVWatts present losses and is far more trustworthy than one opaque "14%" the user has to guess.
4. **Monthly production chart**, not a single number — you already compute `monthlyProduction()` returning 12 values; surface it as a bar chart (the app already depends on `fl_chart`) on the Results screen instead of the single "Monthly kWh" text field currently shown.

### 3.4 Add inverter & string sizing (currently entirely absent)
A real design tool must validate, not just report panel count:
- Inverter entity/catalog (rated AC power, MPPT voltage window, max input current per MPPT, number of MPPTs) — even a small built-in catalog of common inverter models is enough to start.
- String sizing checks: series panel count × Voc-at-minimum-temperature must stay under the inverter's max input voltage; series count × Vmp-at-max-temperature must stay inside the MPPT window; parallel strings' combined Isc must stay under the MPPT max input current.
- DC:AC ratio / clipping estimate — flag when the DC array size is oversized relative to inverter AC rating beyond a sane range (typically 1.1-1.3).
- Surface violations as warnings on the Results/Structure step ("This layout exceeds the inverter's MPPT voltage window in cold climates") rather than silently letting the user export an electrically invalid design.

### 3.5 Add a financial/ROI module
Even a simple version — installed cost input (or $/Wp default), estimated annual utility savings from `yearlyKwh` × electricity rate, simple payback period, and 25-year savings estimate — gives end users the number they actually care about and matches what every competing tool (PVsyst, Aurora, EnergySage-style calculators) leads with.

---

## 4. Fix what's broken or fake (independent of the simulation upgrade)

These are UX-breaking or trust-breaking bugs found during this review, ranked by how visible they'll be to an end user:

1. **"Share & Request Quotes" does nothing but shows a fake success message.** Either implement it against a real backend endpoint or remove/relabel it until it's real — a fake "your proposal has been shared with suppliers" toast is the kind of thing that erodes trust fastest once a real user notices nothing happened.
2. **PDF export shows "Coming soon"** on a button that looks fully functional. Same guidance — implement (the app already has `pdf`/`printing` packages as dependencies, used elsewhere in the app, e.g. accounting) or hide the entry point until ready.
3. **The wizard's own bottom-bar "Save Design" dialog is non-functional** — it has no text field and its Save button doesn't call `saveDesign()` at all; only the equivalent button on the Export step actually works. This is a straightforward bug, not a "coming soon" — worth an immediate fix since it silently fails with no error shown to the user.
4. **`recalculate()` isn't triggered by many state changes** — wall setback/toggles/heights, panel orientation, and every grid edit (cell tap, autofill, clear, rotate) don't call it, so results shown on the Results/Export steps can be stale relative to the latest edits. Route all state mutations through the same debounced recalculation path.
5. **Two big chunks of controller functionality are fully implemented but never wired to any UI**: manual row/column override (`incrementRows/decrementRows/incrementColumns/decrementColumns`, `resetAutoLayout`) and the entire polygon-sketch mode (draw an irregular roof outline and auto-exclude cells outside it). Either surface these — polygon sketching in particular would meaningfully improve usability for irregular roofs — or remove the dead code.
6. **Undo/redo only covers the panel grid**, not roof dimensions, panel specs, or clearances — a user who changes roof width by mistake can't undo it.
7. Known from the earlier codebase-wide review, specific to this feature: the `TextEditingController`-created-per-rebuild leak in `panel_placement_step.dart`'s gap fields, and the systemic `ref.watch(pvSystemDesignerProvider)` (whole-object, no `.select()`) across all 10 files in this feature causing the grid canvas to rebuild on any unrelated state change (e.g., an undo-stack push). Both are detailed with file:line references in the earlier full-app analysis report.

---

## 5. UX/workflow gaps worth closing before a public release

- **No step-completion gating.** A user can tap directly to "Results" or "Export" with an empty grid (0 panels) or a roof/setback combination that yields a degenerate layout, and see a zero/garbage result with no explanation.
- **No cross-field validation or warnings** — e.g., wall setback larger than roof width, panel dimensions that don't fit the roof at all, or manual row/column requests exceeding the roof's capacity.
- **Grid resolution vs. roof size mismatch**: the grid is capped at 25×25 cells while roof dimension inputs allow up to 150m — a large roof modeled at coarse 25×25 resolution no longer represents real panel footprints accurately. Either scale the cap with roof size or clearly communicate the resolution limit.
- **Step naming/flow confusion**: "Panel Specs" (specs only) is immediately followed by "Layout & Shadows" (where placement actually happens), with in-app copy that doesn't make the split clear.
- **Isometric "3D" view is decorative**, not to-scale, and doesn't reflect the user's actual obstacle/tree/shadow placements — worth noting as a "preview" rather than a technical drawing, or investing in a true 3D projection if it's meant to be relied on.

---

## 6. Suggested phased roadmap

**Phase 1 — Trust & correctness (do first, highest leverage per effort)**
Wire up real Open-Meteo irradiance data · add a real solar-position model (date + time based) to replace the shading slider heuristic · fix the broken Save dialog · fix `recalculate()` gaps · connect "Share & Request Quotes" to the existing `offers/requests` backend endpoint (see Section 7 — this is a reuse job, not new backend work) · implement or hide "PDF Export" until real.

**Phase 2 — Real simulation**
POA transposition + temperature derating in the energy model · structured loss diagram (soiling/mismatch/wiring/inverter/degradation) replacing the flat "system losses %" · monthly production chart using the data you already compute · real shading study driven by the sun-position model instead of the wall-adjacency heuristic.

**Phase 3 — Design validity & business value**
Inverter/string sizing with MPPT voltage/current compliance warnings · financial/ROI module (cost input → payback/savings) · real PDF export · cross-field validation and step-completion gating.

**Phase 4 — Polish**
Surface the already-built but unwired polygon-sketch mode for irregular roofs · manual row/column override UI · scale grid resolution with roof size (or communicate the limit) · true-to-scale 3D isometric view reflecting actual obstacles.

---

## 7. Backend cross-check (now verified — folder was connected after initial write-up)

The Python backend (`/Users/rasol/DevsTools/codes/python/solarhub/`) is now reachable and was checked directly. Three things worth acting on:

**No server-side simulation exists anywhere.** A repo-wide search for irradiance/solar-position/shading/tilt/azimuth/weather logic returned nothing. This confirms the client-side calculation engine proposed in Section 3 is not duplicating anything — the backend has zero energy-simulation capability today, so all of it (transposition, temperature derating, loss diagram, sun-position) has to be built, and building it client-side (as proposed) is the right call rather than waiting on backend work.

**"Share & Request Quotes" has a real endpoint to call — it's just not wired up.** The backend `offers` app already implements a working request-for-quote marketplace: `OfferRequest` (created via `POST {baseUrl}/offers/requests`, exposed in the Flutter app as `AppUrls.requestsBaseUrl`) broadcasts to companies, who respond with `Offer` records (price, involvement line items, status workflow), triggering push notifications on both sides (`send_new_solar_request_notification`, `send_new_offer_notification`). The Flutter app already has a full, working implementation of this flow elsewhere — `features/offers/presentation/screens/form/solar_request_form.dart` and `features/calculations/presentation/screens/offer_request_wizard.dart` (810 lines, one of the app's largest files) — so the fix for the PV designer's fake button is very likely **reuse, not build from scratch**: populate an `OfferRequest` from the wizard's computed values (`panel_count`, `panel_power` from the grid/spec, `note` carrying the structural/BOM/energy summary until a PDF attachment path exists) and route it through the same repository/provider the existing offers feature already uses, instead of showing a canned success toast.
Note for whoever implements this: the `OfferRequest`/`Offer` schemas only carry aggregate panel/battery/inverter power+count+notes and a city — there's no field for full design data (grid, frame BOM, sketch, lat/lng). Until a PDF report can be attached, the richer design detail will have to be summarized into the free-text `note` field.

**Saved designs have no backend counterpart — worth a deliberate decision, not an oversight.** `controller.saveDesign()` persists only to local `GetStorage` (per Section 4/earlier review). The backend's `systems` app (`System` model, `POST {baseUrl}/systems/`) is a plausible home for synced designs — it already stores `panel_power/count/type`, `battery_*`, `inverter_*`, `lat`, and a location field the backend spells **`lan`, not `lng`** (an intentional quirk noted in the model's own comment — worth remembering if this integration is built, to avoid a silent field-name mismatch). As-is, `System` is a flat spec record with no room for the grid/BOM/sketch detail either, so syncing "Save Design" to the backend would need either a schema extension (e.g. a JSON `design_data` field) or the same note-field workaround as the offer-request case above. Recommend deciding explicitly whether saved designs should sync to the account (cross-device access, admin visibility) or stay local-only — currently it's local-only by default, not by design choice.

---

*Methodology: full read of all 30 files in `lib/src/features/pv_system_designer` (domain entities/services read directly; presentation layer — controller, screens, all 7 wizard steps, canvas, sketch painters — read via a scoped research pass), cross-checked against confirmed details of the Open-Meteo and PVGIS free APIs, and against the Python backend (`systems` and `offers` apps: models, ninja API schemas, endpoints) once that folder was connected.*
