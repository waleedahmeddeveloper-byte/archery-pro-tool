# Package decision log

| Package | Why | Alternatives considered |
| --- | --- | --- |
| Flutter stable 3.x | Single codebase Android+iOS, strong offline story | React Native, native Kotlin/Swift |
| Riverpod | Compile-safe DI/state, testable, popular | Bloc, Provider |
| GoRouter | Nested nav + shell routes for bottom tabs | auto_route |
| SharedPreferences | Tiny settings (theme, onboarding) | Hive (heavier for keys only) |
| fl_chart | Lightweight charts for drop/KE | syncfusion (heavier license) |
| google_mobile_ads | Official AdMob SDK behind feature flag | None for AdMob |
| path dependency `archery_engine` | Pure Dart, no Flutter in formulas | inline lib/ (harder to reuse/test) |
| Drift/Isar | Deferred to next phase for profiles/history | — |

Pinned via pubspec version constraints; run `flutter pub outdated` before releases.
