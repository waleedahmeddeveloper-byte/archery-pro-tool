# iOS release checklist (no macOS in this environment)

This Linux agent **cannot** run Xcode, create signing certificates, or produce an IPA. Complete the following on a Mac with Xcode 15+.

## 1. Signing & bundle ID

- [ ] Open `apps/arcus/ios/Runner.xcworkspace` in Xcode
- [ ] Set unique **Bundle Identifier** (replace default `com.arcus.arcus` if needed)
- [ ] Select Team → enable **Automatically manage signing** (or install distribution cert + App Store profile)
- [ ] Archive → Distribute App → App Store Connect / TestFlight
- [ ] Confirm `CFBundleShortVersionString` / `CFBundleVersion` match `apps/arcus/pubspec.yaml` (`0.1.0+1`)

```bash
cd apps/arcus
flutter build ipa --release
```

## 2. Info.plist permissions

Current template keys are launch/orientation only (verified earlier). Add **only when a feature needs them**:

| Key | When required |
| --- | --- |
| `NSUserTrackingUsageDescription` | AdMob personalized ads / ATT |
| `NSPhotoLibraryUsageDescription` | If saving/sharing screenshots to Photos |
| `NSCameraUsageDescription` | If a future camera chronograph feature lands |
| `ITSAppUsesNonExemptEncryption` = `NO` | Export compliance if only HTTPS |

Calculators + local profiles do **not** need location, contacts, or mic.

## 3. ATT / privacy (ads)

Ads are **disabled** (`AdService.adsEnabled = false`). Before enabling AdMob:

- [ ] Add `NSUserTrackingUsageDescription` explaining tracking
- [ ] Integrate UMP / ATT prompt **before** requesting IDFA
- [ ] Update App Store Privacy Nutrition Labels (advertising data)
- [ ] Update in-app Privacy policy text

## 4. Privacy Manifest (PrivacyInfo.xcprivacy)

Apple requires a privacy manifest for certain APIs. When shipping:

- [ ] Add `ios/Runner/PrivacyInfo.xcprivacy` declaring:
  - UserDefaults / File timestamp APIs if used by plugins (`shared_preferences`, `path_provider`)
  - Reason codes per Apple’s required-reason API list
- [ ] Confirm Flutter / plugin versions include their own manifests
- [ ] Run Xcode Organizer privacy report on the archive

## 5. Networking

- [ ] ATS: keep HTTPS for `ARCUS_API_BASE` (no cleartext)
- [ ] Test content sync on device (More → Refresh) with production API
- [ ] Confirm offline launch still works with airplane mode

## 6. Smoke test on device / simulator

- [ ] Onboarding Skip / Get started
- [ ] Setup Assistant 5 steps + Save/Load profile
- [ ] One calculator from each category + search empty state
- [ ] Light / Dark navy theme
- [ ] Airplane mode: calculators still work

## 7. Store listing

- [ ] Screenshots (6.7" / 6.1" / iPad if supporting)
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] Age rating / hunting disclaimer if required by region
