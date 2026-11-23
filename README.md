# Arcus

Offline-first professional archery calculators for **Android** and **iOS** (Flutter), with a pure-Dart calculation engine and optional website content sync.

> Results are planning estimates. Chronograph, inspect, and tune equipment with a qualified professional before hunting or competition.

## What’s in this repo

| Path | Purpose |
| --- | --- |
| `apps/arcus` | Flutter application (Riverpod + GoRouter) |
| `packages/archery_engine` | Pure-Dart formulas, charts helpers, citations, unit tests |
| `docs/research` | Reference-site inventory (feature reference only) |
| `docs/product` | IA / product spec |
| `docs/design` | Design system |
| `docs/api/openapi.yaml` | Content sync API contract for the website |
| `docs/qa` | Test report & limitations |
| `DECISIONS.md` | Package choice log |

## Brand

**Arcus** — spruce + brass design system (original; not copied from any reference site).

## Quick start

```bash
# Flutter SDK required (stable)
export PATH="$PATH:$HOME/sdk/flutter/bin"   # or your install path

# Engine tests
cd packages/archery_engine && dart test

# App
cd ../../apps/arcus
flutter pub get
flutter run -d linux   # or chrome / android / ios
```

### Android release

```bash
cd apps/arcus
flutter build appbundle --release
# APK: flutter build apk --release
```

Configure signing in `android/key.properties` (not committed).

### iOS release

```bash
cd apps/arcus
flutter build ipa --release
```

Open `ios/Runner.xcworkspace` in Xcode for signing, capabilities (ATT when ads enabled), and TestFlight upload.

## Architecture

- **Clean / feature-first** folders under `apps/arcus/lib/features`
- **Engine** has zero Flutter dependencies
- **Ads** behind `AdService` with `adsEnabled = false` and Google test IDs only
- **Sync** mocked in-app; implement `docs/api/openapi.yaml` on the website

## Safety & citations

Every calculator result surfaces formula, steps, assumptions, limitations, safety notes, and a citation object from `archery_engine`.

## License

Proprietary — all rights reserved unless otherwise stated by the owner.
