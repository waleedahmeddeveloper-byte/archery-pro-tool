# Test report — Arcus

**Date:** 2026-11-23

## Commands

```bash
# Engine
cd packages/archery_engine && dart analyze && dart test --coverage=coverage
format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

# App
cd apps/arcus && flutter analyze && flutter test --coverage
flutter test integration_test/app_flows_test.dart -d linux
```

## Results

| Suite | Pass |
| --- | --- |
| Engine analyze | 0 issues |
| Engine unit | 53 |
| App analyze | 0 issues |
| App unit/widget | 10 |
| App integration (linux) | 4 |

## Coverage

| Target | % |
| --- | --- |
| Engine (`lib/`) | **97.4%** (645/662) |
| App (`lib/`) | **44.0%** (631/1435) |

## Integration coverage map

| Flow | Test |
| --- | --- |
| Onboarding → home | `onboarding then offline home launch` |
| Skip → offline home | `skip onboarding reaches home offline` |
| Setup Assistant steps 1–5 + save profile | `Setup Assistant 5 steps + save/load profile` |
| Search empty + FOC / Draw Length / KE / Spine / Crossbow / Unit Converter | `search and one calculator per category` |
