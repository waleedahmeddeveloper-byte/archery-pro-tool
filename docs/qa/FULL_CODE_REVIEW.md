# Full code review — Arcus (updated)

**Date:** 2026-11-23 (follow-up)  
**Repo:** `waleedahmeddeveloper-byte/archery-pro-tool`  
**Scope:** Entire monorepo after integration/widget tests, coverage gate, signing docs, sync API client, iOS checklist.  
**Method:** Static review + `dart analyze` / `flutter analyze` + unit/widget + Linux integration tests + lcov. No guess for unverified items.

---

## Coverage (measured)

| Package | Lines hit | Total | % | Target |
| --- | --- | --- | --- | --- |
| `packages/archery_engine` | 645 | 662 | **97.4%** | ≥95% — **met** (CI gate in `.github/workflows/ci.yml`) |
| `apps/arcus` | 631 | 1435 | **44.0%** | No hard gate (UI surface is large); widget + integration cover main flows |

---

## Test results (this pass)

| Suite | Result |
| --- | --- |
| `packages/archery_engine` `dart analyze` | Pass (0 issues) |
| `packages/archery_engine` `dart test` | **53 passed** |
| `apps/arcus` `flutter analyze` | Pass (0 issues) |
| `apps/arcus` `flutter test` | **10 passed** (onboarding smoke, scaffold Calculate/Reset/Copy, FOC/GPP/unknown calc, profile + sync client) |
| `apps/arcus` `integration_test/app_flows_test.dart` (-d linux) | **4 passed**: onboarding, skip→offline home, Setup Assistant 5 steps + save profile, search empty + one calc per category |
| iOS build / Xcode | **Not run** (no macOS) — see `docs/ios/IOS_RELEASE_CHECKLIST.md` |
| Android release keystore | Configured via `key.properties` when present; secrets **not** committed |

---

## 1. Prioritized issues

### Critical

| ID | Issue | File:line | Cause | Fix | Status |
| --- | --- | --- | --- | --- | --- |
| — | None verified | — | — | — | — |

### High

| ID | Issue | File:line | Cause | Fix | Status |
| --- | --- | --- | --- | --- | --- |
| H1 | GPP could show NaN/Infinity | `generic_calculator_page.dart` | Inline division | Route through engine `grainsPerPound` | **Fixed** (prior) |
| H2 | Point FOC accepted NaN percents | `point_foc.dart` | Missing finite checks | `requireFiniteNumber` | **Fixed** (prior) |
| H3 | Release APK unsigned / debug-signed without owner keystore | `android/app/build.gradle.kts` | No secrets in repo | Reads `android/key.properties`; docs in `docs/android/RELEASE_SIGNING.md`; debug fallback for CI only | **Mitigated** — owner must supply keystore before Play upload |
| H4 | Content API host is placeholder | `content_api_client.dart` `kArcusApiBase` | Website API not live | OpenAPI at `docs/api/openapi.yaml`; client has retry/backoff + disk cache offline fallback; override via `--dart-define=ARCUS_API_BASE=` | **Open** (blocked on website deploy) |

### Medium

| ID | Issue | File:line | Cause | Fix | Status |
| --- | --- | --- | --- | --- | --- |
| M1 | Setup Assistant Done no-op | `setup_assistant_page.dart` | Step guard | `context.go('/')` | **Fixed** |
| M2 | Marketing ahead of profile feature | onboarding/home/privacy | Copy drift | Aligned + `RigProfileStore` | **Fixed** |
| M3 | Prefs hit every GoRouter redirect | `onboarding_gate.dart` | Async prefs | Cache | **Fixed** |
| M4 | Sync was mock-only | `sync_status_provider.dart` | Stub delay | Real `ContentApiClient` + OpenAPI | **Fixed** |
| M5 | Calculators search empty state | `calculators_tab.dart` | Missing UI | Empty message | **Fixed** |
| M6 | App line coverage ~44% | `apps/arcus/lib` | Large UI / routes | Integration + widget cover critical paths; raise later with more widget tests | Open |
| M7 | Duplicate catalog IDs share runners | `calculator_catalog.dart` | Overlapping product entries | Documented; behavior OK | Open (product) |
| M8 | Main manifest now has INTERNET | `AndroidManifest.xml` | Needed for content sync | Keep; sync fails soft to offline cache | Accepted |

### Low

| ID | Issue | File:line | Cause | Fix | Status |
| --- | --- | --- | --- | --- | --- |
| L1 | Application ID `com.arcus.arcus` | `build.gradle.kts` | Scaffold default | Owner sets Play/App Store ID | Open |
| L2 | Catalog ListView eager children | `calculators_tab.dart` | ~50 items | `ListView.builder` if catalog grows | Open |
| L3 | `material_ui` wrapper | throughout | Extra dep | Keep unless migrating | Open |
| L4 | Limited Semantics on charts | FOC visual / lists | No explicit labels | Future a11y pass | Open |
| L5 | Integration search needs TextField focus after nav tap | `app_flows_test.dart` | NavBar tap steals focus; `enterText` no-op | Tests tap field before `enterText` | **Fixed** (test harness) |
| L6 | iOS PrivacyInfo.xcprivacy not authored here | `ios/Runner` | No macOS/Xcode | Checklist in `docs/ios/IOS_RELEASE_CHECKLIST.md` | Open (Mac required) |

---

## 2. Deliverables from this follow-up

1. **Integration tests** — onboarding, offline home, Setup Assistant (5 steps) + save profile, search + one calculator per category  
2. **Widget tests** — `CalculatorScaffold` Calculate/Reset; `ResultBreakdown` Copy; `GenericCalculatorPage` validation / Calculate / Reset / Copy / errors  
3. **Coverage** — engine **97.4%** (CI ≥95%); app **44.0%** reported  
4. **Release signing** — Gradle reads `key.properties` (gitignored); `key.properties.example` + `docs/android/RELEASE_SIGNING.md`  
5. **Sync** — `ContentApiClient` (HTTPS, retry/backoff, disk cache, offline fallback) + `docs/api/openapi.yaml`  
6. **iOS** — `docs/ios/IOS_RELEASE_CHECKLIST.md` (signing, Info.plist, ATT, privacy manifest)

---

## 3. Remaining risks

- Store release stays **debug-signed** until the owner adds a real keystore via `key.properties`.  
- Live content sync needs a website implementing `docs/api/openapi.yaml` and `ARCUS_API_BASE`.  
- iOS IPA / ATT / Privacy Manifest **must** be completed on a Mac.  
- App coverage is modest outside the exercised flows; expand widget tests for More/Library/theme if raising the bar.
