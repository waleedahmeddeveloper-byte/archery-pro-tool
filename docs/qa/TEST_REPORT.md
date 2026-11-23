# Arcus QA report

## Scope

Offline Flutter app (`apps/arcus`) + pure-Dart engine (`packages/archery_engine`).

## Automated

| Suite | Result |
| --- | --- |
| `packages/archery_engine` `dart test` | Pass (21 cases): FOC, KE/momentum, weight/GPP, speed, draw length, spine, trajectory, converters, let-off, shot angle, crossbow, bow energy, sight pin, point FOC |
| `apps/arcus` `flutter analyze` | Pass (no issues) |
| `apps/arcus` widget smoke | Onboarding loads when unseen |

## Manual / product coverage

- Full calculator catalog (50+ tools) routed via `/calc/:id` with shared scaffold: breadcrumb, intro, inputs, calculate/reset/copy, formula, steps, assumptions, limitations, safety, citation, FAQ/examples when defined, related tools.
- Setup Assistant 5-step workflow: bow → shaft → components → performance → related tools.
- FOC balance diagram (2D with cylindrical shading).
- Trajectory / drop charts via `fl_chart`.
- Light (spruce/brass) and dark navy themes.
- Ads stub (`AdService.adsEnabled = false`) ready for AdMob/AdSense later.
- Website sync contract in `docs/api/openapi.yaml` (mock status in-app).

## Known limitations (honest)

- Spine charts are **Arcus planning bands**, not reproduced manufacturer charts.
- IBO→speed, drag trajectory, and sight-pin gaps are **labeled estimates**.
- Component FOC ≠ measured AMO FOC — both are offered separately.
- Crossbow guidance never overrides the owner’s manual minimum bolt weight.
- No claim of “zero bugs” in production; continue chronograph and paper-tune validation.
- Release APK may be debug-signed until store keystores are configured.
- iOS IPA requires macOS + Apple signing (not produced in this Linux CI environment).

## Ads / monetization readiness

- Abstraction in place; Google Mobile Ads SDK not linked yet (keeps APK builds reliable).
- When enabling: production AdMob unit IDs, UMP/ATT consent, and store privacy disclosures.
