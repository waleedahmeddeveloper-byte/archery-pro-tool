# Android release signing

Secrets stay out of git. `android/key.properties` is gitignored.

## Steps

1. Create an upload keystore (once):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Copy the example file:

```bash
cp apps/arcus/android/key.properties.example apps/arcus/android/key.properties
```

3. Edit `apps/arcus/android/key.properties`:

```properties
storePassword=***
keyPassword=***
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

4. Build:

```bash
cd apps/arcus
flutter build appbundle --release
# or: flutter build apk --release
```

## Missing key.properties

**Release builds fail** with a clear Gradle error if `android/key.properties` is missing.

Debug-signed release is allowed **only** when:

- `CI=true` (GitHub Actions sets this), or
- you pass `-PallowDebugReleaseSigning=true`

```bash
# CI / local throwaway artifact only — do NOT upload to Play
flutter build appbundle --release --android-project-arg=allowDebugReleaseSigning=true
```

Do **not** ship a debug-signed AAB/APK to Play Store.

## Verify

```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
# or for APK:
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```
