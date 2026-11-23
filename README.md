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

**Arcus** — spruce + brass (light) and dark navy themes (original; not copied from any reference site).

## Calculators

50+ tools across arrow build, bow performance, hunting energy/ballistics, spine & tuning, crossbow, converters, plus the guided **Setup Assistant**. Every result shows formula, steps, assumptions, limitations, safety notes, and citations from `archery_engine`.

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

**Download Android build:** see full checklist in [DOWNLOAD.md](./DOWNLOAD.md).

Fast path (recommended): open [dist/arcus-android.zip](https://github.com/waleedahmeddeveloper-byte/archery-pro-tool/blob/main/dist/arcus-android.zip) → click **Download raw file** → unzip → install `arcus-release.apk`.

```bash
cd apps/arcus
flutter build appbundle --release
# APK: flutter build apk --release
```

Release signing: copy `android/key.properties.example` → `android/key.properties` (gitignored). Steps: [docs/android/RELEASE_SIGNING.md](./docs/android/RELEASE_SIGNING.md).

### iOS release

```bash
cd apps/arcus
flutter build ipa --release   # requires macOS + Xcode
```

Checklist (signing, Info.plist, ATT, privacy manifest): [docs/ios/IOS_RELEASE_CHECKLIST.md](./docs/ios/IOS_RELEASE_CHECKLIST.md).

### Content sync API

OpenAPI contract: [docs/api/openapi.yaml](./docs/api/openapi.yaml).  
App client: `ContentApiClient` with HTTPS, retry/backoff, disk cache, offline fallback.  
Override base URL: `--dart-define=ARCUS_API_BASE=https://your-api/v1`.

## Architecture

- **Clean / feature-first** folders under `apps/arcus/lib/features`
- **Engine** has zero Flutter dependencies
- **Ads** behind `AdService` with `adsEnabled = false` and Google test IDs only
- **Sync** mocked in-app; implement `docs/api/openapi.yaml` on the website

## Safety & citations

Every calculator result surfaces formula, steps, assumptions, limitations, safety notes, and a citation object from `archery_engine`.

## License

Proprietary — all rights reserved unless otherwise stated by the owner.
