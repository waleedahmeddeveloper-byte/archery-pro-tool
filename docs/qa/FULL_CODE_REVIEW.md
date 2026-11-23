# Full code review — Arcus (updated)

**Date:** 2026-11-23 (release-readiness follow-up)  
**Repo:** `waleedahmeddeveloper-byte/archery-pro-tool`  
**Scope:** Integration on Android emulator, signing gate, app coverage ≥70%, lazy catalog + a11y, release checklist, release AAB.  
**Method:** Emulator IT + `flutter analyze` / unit+widget tests + lcov + `flutter build appbundle --release`. No guess for unverified items.

---

## Coverage (measured)

| Package | Lines hit | Total | % | Target |
| --- | --- | --- | --- | --- |
| `packages/archery_engine` | 645 | 662 | **97.4%** | ≥95% — **met** |
| `apps/arcus` | 1225 | 1488 | **82.3%** | ≥70% — **met** |

---

## Android emulator integration tests

Device: `emulator-5554` (AVD `arcus_api34`, API 34). Command: `flutter test integration_test/app_flows_test.dart -d emulator-5554`.

| # | Test | Result |
| --- | --- | --- |
| 1 | onboarding then offline home launch | **PASS** |
| 2 | skip onboarding reaches home offline | **PASS** |
| 3 | Setup Assistant 5 steps + save/load profile | **PASS** |
| 4 | search and one calculator per category | **PASS** |

**Totals: 4 passed / 0 failed.**

---

## Release AAB

| Item | Value |
| --- | --- |
| Artifact | `apps/arcus/build/app/outputs/bundle/release/app-release.aab` |
| Size | **53,303,853 bytes (~50.8 MiB / Flutter reports 53.3MB)** |
| Signing | Ephemeral upload keystore via local `key.properties` (not committed) |
| Without `key.properties` | **Fails** with clear Gradle error (verified) |
| CI debug-signed escape | `CI=true` or `-PallowDebugReleaseSigning=true` |

### Build warnings (observed)

- Icon font tree-shaking: CupertinoIcons 99.7%, MaterialIcons 99.8% (informational)
- `Caught exception: Already watching path: .../android` (Gradle file watcher noise; build succeeded)
- JKS keystore format advisory from `keytool` when generating a local upload key (prefer PKCS12 for production)

No Dart analyzer issues. No shipping blockers in the warning set above.

---

## 1. Prioritized issues

### Critical

| ID | Issue | Status |
| --- | --- | --- |
| — | None verified | — |

### High

| ID | Issue | Status |
| --- | --- | --- |
| H1–H2 | NaN / validation gaps (GPP, point FOC) | **Fixed** (prior) |
| H3 | Release could ship debug-signed | **Fixed** — missing `key.properties` fails release; debug fallback only for CI / `-PallowDebugReleaseSigning=true` |
| H4 | Content API host placeholder | **Open** — client + OpenAPI ready; set `ARCUS_API_BASE` when website is live |
| H5 | Placeholder application id `com.arcus.arcus` | **Open** — owner must set Play ID before store upload (checklist) |

### Medium

| ID | Issue | Status |
| --- | --- | --- |
| M1–M5 | Assistant Done, profiles, prefs cache, sync mock, search empty | **Fixed** |
| M6 | App coverage was ~44% | **Fixed** — **82.3%** |
| M7 | Catalog ListView eager children | **Fixed** — `ListView.builder` lazy rows |
| M8 | Accessibility (labels / contrast / 200% text) | **Mitigated** — semantics on search/list/nav/FOC/CTAs; contrast tokens; text-scale widget test |
| M9 | `integration_test` could break release Java compile | **Mitigated** — Gradle strips registrant registration for release |
| M10 | Default Flutter launcher icons / splash | **Open** — checklist item for brand assets |

### Low

| ID | Issue | Status |
| --- | --- | --- |
| L1 | Duplicate catalog IDs sharing runners | Open (product) |
| L2 | iOS PrivacyInfo / signing | Open — Mac checklist only |
| L3 | Play Data Safety / hosted privacy URL | Open — answers drafted in checklist |
| L4 | AAB ~53MB | Informational — includes engine + Material; minify/split later if needed |

---

## 2. Deliverables this follow-up

1. Android emulator IT — **4/4 pass** (table above)  
2. Release signing gate + CI/debug escape hatch + docs  
3. App coverage **82.3%** (profile, sync/offline, settings, search, catalog calculators, Assistant)  
4. Lazy calculator catalog + a11y labels/contrast/200% scale test  
5. `docs/android/RELEASE_READINESS_CHECKLIST.md` (app ID, versions, icons, splash, permissions, privacy, Data Safety)  
6. Release AAB built and sized  
7. This report  

---

## 3. Remaining risks

- Owner must replace `com.arcus.arcus`, icons/splash, and supply production keystore before Play.  
- Live sync needs website implementing OpenAPI.  
- iOS IPA still requires macOS.  
- Ephemeral CI keystore used only to measure AAB size here — **not** for store upload.
