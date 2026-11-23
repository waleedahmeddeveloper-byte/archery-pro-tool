# Full code review — Arcus

**Date:** 2026-11-23  
**Repo:** `waleedahmeddeveloper-byte/archery-pro-tool`  
**Scope:** Entire monorepo (`apps/arcus`, `packages/archery_engine`, configs, dist/docs).  
**Method:** Static review + `dart analyze` / `flutter analyze` + unit/widget tests. No guess for unverified items.

---

## 1. File download code (in-app)

**Finding (verified):** There is **no in-app file-download implementation**.

| Check | Result |
| --- | --- |
| `http` / `dio` / `HttpClient` / download APIs in Dart | **None found** (`rg` over `apps/arcus`) |
| Scoped storage / iOS sandbox download paths | **N/A** — no download module |
| Progress / pause / resume / cancel / retry | **N/A** |
| APK distribution | **Outside the app** — GitHub `dist/arcus-android.zip` + Releases (see `DOWNLOAD.md`) |

Privacy/sync copy previously implied downloads; copy was corrected to match mock sync (no network).

**Android INTERNET:** present only in `debug`/`profile` manifests (Flutter tooling). **Main/release manifest has no INTERNET permission** (verified in `android/app/src/main/AndroidManifest.xml`) — appropriate for offline-first calculators.

---

## 2. Prioritized issues

### Critical

| ID | Issue | File:line | Cause | Fix |
| --- | --- | --- | --- | --- |
| — | None verified | — | — | — |

### High

| ID | Issue | File:line | Cause | Fix | Status |
| --- | --- | --- | --- | --- | --- |
| H1 | GPP could show NaN/Infinity | `generic_calculator_page.dart` (GPP case) | Inline `total/draw` skipped engine validation | Route through `ArcheryEngine.grainsPerPound` → `calculateGppResult` | **Fixed** |
| H2 | Point FOC accepted NaN percents | `point_foc.dart:14-15` | Only length/mass validated | `requireFiniteNumber` on FOC % inputs | **Fixed** |
| H3 | Release build uses debug signing | `android/app/build.gradle.kts` release `signingConfig` | Placeholder for local release | Needs owner keystore (`key.properties`) — **not auto-fixed** (needs secrets) | Open |

### Medium

| ID | Issue | File:line | Cause | Fix | Status |
| --- | --- | --- | --- | --- | --- |
| M1 | Setup Assistant “Done” no-op | `setup_assistant_page.dart` Done button | Only advanced when `_step < 4` | `context.go('/')` on final step | **Fixed** |
| M2 | Onboarding promised saved profiles | `app_strings.dart`, `home_tab.dart`, `privacy_page.dart` | Marketing ahead of features | Copy aligned to Assistant + offline reality | **Fixed** |
| M3 | GoRouter hit SharedPreferences every nav | `app_router.dart` redirect | Async prefs each redirect | `OnboardingGate` cache | **Fixed** |
| M4 | Unused deps / `generate: true` without l10n | `pubspec.yaml` | Dead `uuid`/`intl`/`collection`/`meta`/`flutter_localizations` | Removed unused; `generate: false` | **Fixed** |
| M5 | Calculators search had no empty state | `calculators_tab.dart` | No `filtered.isEmpty` UI | Empty search message | **Fixed** |
| M6 | Unused imports | `crossbow.dart`, `downrange.dart` | `units.dart` unused | Removed | **Fixed** |
| M7 | Duplicate catalog tools share one runner | `calculator_catalog.dart` | Overlapping IDs (foc/balance, spine-adj, …) | Documented; behavior OK | Open (product) |
| M8 | Sync UI implies network | `sync_status_provider.dart` | Mock delay only | Message says mock / no network | **Fixed** |

### Low

| ID | Issue | File:line | Cause | Fix | Status |
| --- | --- | --- | --- | --- | --- |
| L1 | Application ID placeholder | `build.gradle.kts` `com.arcus.arcus` | Scaffold default | Owner should set Play ID | Open |
| L2 | No integration / golden tests | `apps/arcus/test` | Only 1 widget smoke | Expand later | Open |
| L3 | Catalog lists rebuild full `ListView` children | `calculators_tab.dart` | ~50 items — fine for now | Lazy `ListView.builder` if catalog grows | Open |
| L4 | `material_ui` wrapper vs `flutter/material` | throughout | Extra dep | Keep unless migrating | Open |
| L5 | Accessibility: limited Semantics | lists / charts | No explicit labels on charts | Future a11y pass | Open (unverified beyond visual) |
| L6 | Coverage % | — | No `lcov` run in CI | Coverage tool not run this session — **not quantified** | Unverified |

---

## 3. Lists audit

| List | Pagination | Lazy load | Empty | Loading | Error | Search/filter | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Calculators tab | N/A (static ~49) | No (eager children) | **Added** | N/A (sync data) | N/A | Search title/subtitle | OK for size |
| Home featured | Take 6 | SliverList | N/A | N/A | N/A | No | OK |
| Library guides | Static 6 | Eager | N/A | N/A | N/A | No | OK |
| More settings | Static | Eager | N/A | Sync subtitle | Mock only | No | OK |
| Assistant steps | PageView | Eager | N/A | N/A | Validation text | No | Done fixed |
| Calculator results | Nested lists | Eager | No result until Calculate | N/A | Error string | Related chips | OK |

No infinite scroll or remote lists exist (verified).

---

## 4. Testing

| Suite | Result |
| --- | --- |
| `packages/archery_engine` `dart analyze` | Pass (0 issues after fixes) |
| `packages/archery_engine` `dart test` | **25 passed** (was 21; +GPP + FOC NaN) |
| `apps/arcus` `flutter analyze` | Pass |
| `apps/arcus` `flutter test` | **1 passed** (onboarding smoke) |
| Integration tests | **None present** — cannot report |
| Coverage % | **Not measured** this session |
| iOS build / Xcode warnings | **Not run** (no macOS in this environment) |
| Android `flutter build apk` | Previously succeeded; not re-run this review pass |

---

## 5. Changes applied this review

1. `calculateGppResult` + `ArcheryEngine.grainsPerPound`; GPP UI uses engine  
2. `requireFiniteNumber` + FOC % validation in `point_foc.dart`  
3. Setup Assistant Done → home  
4. Onboarding/home/privacy copy corrected  
5. `OnboardingGate` prefs cache  
6. Calculators empty search UI  
7. Removed unused pubspec deps; `generate: false`  
8. Removed unused engine imports  
9. Sync mock message clarified  
10. Engine tests for GPP + NaN FOC  

---

## 6. Remaining risks

- Store release still **debug-signed** until keystore is configured.  
- No live sync / ads — stubs only.  
- Spine “adjustment” catalog entries do not show isolated deltas.  
- Single widget test — low UI regression coverage.  
- iOS IPA / ATT / store compliance **not verified** here.
