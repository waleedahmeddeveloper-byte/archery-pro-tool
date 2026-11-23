# Arcus QA report (phase 1)

**Date:** 2026-11-23  
**Scope:** Calculation engine + Flutter app shell  
**Claim:** Not “bug-free”. Below is what was tested and known limits.

## Automated

| Suite | Result |
| --- | --- |
| `packages/archery_engine` unit tests | 17/17 passed |
| Coverage targets | Core formulas covered (FOC, KE, momentum, weight, speed, spine, trajectory, converters, let-off, shot angle). Aim ≥95% engine LOC in a later `coverage` CI job. |
| Flutter analyzer | Run in CI / local `flutter analyze` |
| Widget/golden tests | Minimal smoke TBD after first UI freeze |

## Manual matrix (planned / partial)

| Case | Status |
| --- | --- |
| Offline calculator use | Designed offline-first; no network required for math |
| Invalid / zero inputs | ValidationException paths unit-tested |
| Theme light / dark navy / system | Implemented in More tab |
| Setup Assistant end-to-end | Implemented; needs device UX pass |
| iOS / Android release builds | Requires local Xcode / Android SDK signing — instructions in README |
| AdMob | Disabled (`AdService.adsEnabled = false`) |
| Sync API | Mock only until website implements OpenAPI |

## Known limitations

1. Spine chart is an Arcus planning heuristic — not a manufacturer chart reproduction.  
2. Trajectory drag model is first-order and must be calibrated.  
3. Profile persistence (Drift/Isar), PDF export, home widgets, and 3D visualizer are roadmap items.  
4. google_mobile_ads may require platform config before enabling ads.  
5. No Firebase/Sentry wired yet — hooks documented for next phase.

## Roadmap priority

1. Persist profiles/history (Drift)  
2. Expand calculator FAQ/examples content  
3. Manufacturer chart import format (user-provided CSV)  
4. Chronograph logging  
5. Enable ads behind consent once IDs supplied  
6. Crashlytics/Sentry  
7. Store screenshots + TestFlight/Play internal testing
