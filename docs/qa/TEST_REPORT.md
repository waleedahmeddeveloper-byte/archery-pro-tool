# Test report — Arcus

**Date:** 2026-11-23

## Commands

```bash
cd packages/archery_engine && dart analyze && dart test --coverage=coverage
format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

cd apps/arcus && flutter analyze && flutter test --coverage
flutter test integration_test/app_flows_test.dart -d emulator-5554   # or linux
```

## Results

| Suite | Pass |
| --- | --- |
| Engine analyze | 0 issues |
| Engine unit | 53 |
| App analyze | 0 issues |
| App unit/widget | **27** |
| App integration (Android emulator) | **4 / 4** |
| App integration (Linux, prior) | 4 / 4 |

### Android emulator per-test

| Test | Result |
| --- | --- |
| onboarding then offline home launch | PASS |
| skip onboarding reaches home offline | PASS |
| Setup Assistant 5 steps + save/load profile | PASS |
| search and one calculator per category | PASS |

## Coverage

| Target | % |
| --- | --- |
| Engine (`lib/`) | **97.4%** (645/662) |
| App (`lib/`) | **82.3%** (1225/1488) |

## Release AAB

| Field | Value |
| --- | --- |
| Size | 53,303,853 bytes (~50.8 MiB) |
| Path | `apps/arcus/build/app/outputs/bundle/release/app-release.aab` (local build artifact; gitignored) |
