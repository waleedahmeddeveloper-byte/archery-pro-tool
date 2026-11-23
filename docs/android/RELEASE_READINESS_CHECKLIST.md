# Android / Play release-readiness checklist

Complete before uploading an AAB to Play Console. Secrets never go in git.

## 1. App identity

- [ ] **Application ID** set for production (replace scaffold `com.arcus.arcus` in `android/app/build.gradle.kts` / iOS bundle ID)
- [ ] **App name** “Arcus” confirmed in launcher label (`AndroidManifest` / `Info.plist`)
- [ ] Unique Play listing title / short description ready

## 2. Version & build numbers

- [ ] `apps/arcus/pubspec.yaml` `version:` is `x.y.z+build` (name + `versionCode`)
- [ ] `versionCode` / `CFBundleVersion` increments for every Play upload
- [ ] Changelog / “What’s new” drafted for this build

## 3. Signing

- [ ] `android/key.properties` present locally (gitignored)
- [ ] Upload keystore backed up offline; Play App Signing enrolled
- [ ] `flutter build appbundle --release` succeeds **without** `allowDebugReleaseSigning`
- [ ] AAB signed with upload key (not debug)

## 4. Icons & splash

- [ ] Launcher icons for mdpi→xxxhdpi (or adaptive icon) — replace Flutter defaults
- [ ] Adaptive icon foreground/background contrast checked
- [ ] Splash / launch screen matches brand (no default Flutter mark)
- [ ] Feature graphic + phone screenshots for Play listing

## 5. Permissions

Current main manifest:

| Permission | Purpose | Keep? |
| --- | --- | --- |
| `INTERNET` | Optional HTTPS content sync | Yes if sync enabled; remove only if sync shipped off forever |

- [ ] No unused dangerous permissions (location, camera, mic, storage)
- [ ] If AdMob later: declare ad ID / ATT strings and update this table
- [ ] Privacy policy text matches declared permissions

## 6. Privacy policy

- [ ] Hosted HTTPS privacy policy URL (in-app page alone is not enough for Play)
- [ ] In-app **Privacy policy** screen (`/privacy`) matches hosted copy
- [ ] Disclose: on-device profiles, optional content sync cache, no account for core math
- [ ] Disclose ads only when AdMob is enabled

## 7. Play Data Safety answers (suggested)

Use these as a starting point; re-verify before submit:

| Question | Suggested answer | Notes |
| --- | --- | --- |
| Does the app collect/share user data? | **No** (core) / **Yes** if sync or ads live | Calculators + profiles are on-device only today |
| Personal info | Not collected | No account |
| Financial / health / messages | Not collected | — |
| Location | Not collected | — |
| App activity / diagnostics | Not collected unless you add crashlytics later | Disclose if added |
| Device IDs | Not collected unless AdMob | AdMob may use advertising ID |
| Data encrypted in transit? | Yes for sync (HTTPS) | When `ARCUS_API_BASE` is set |
| Users can request deletion? | N/A for local-only; document if cloud accounts appear | |

## 8. Content / policy

- [ ] Hunting / archery disclaimer present (in-app + listing if required)
- [ ] Target audience / age rating set (typically PEGI/ESRB tools)
- [ ] No misleading “download APK” claims inside the app

## 9. Pre-upload smoke

- [ ] Release AAB installs via internal testing track
- [ ] Airplane mode: onboarding skip, calculators, Assistant, saved profile
- [ ] More → Content sync Refresh soft-fails to offline when API down
- [ ] Light + Dark navy themes; system font scale 200% spot-check

## 10. Artifacts to archive

- [ ] AAB file + SHA-256
- [ ] `key.properties` / keystore backup location (offline)
- [ ] Mapping/symbols if minify enabled later
