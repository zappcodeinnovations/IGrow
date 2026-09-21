# 🚀 IGrow - Release & Deployment Guide

This guide details the step-by-step procedure to generate production release binaries for **Google Play Store (.aab / .apk)** and **Apple App Store (.ipa)** for the **IGrow** Flutter app.

---

## 📋 1. Prerequisites

Before generating release builds, ensure:
1. Flutter SDK (`>= 3.9.0`) and Dart are installed and added to PATH.
2. Android SDK & Build Tools are installed.
3. Keystore file (`key.jks`) is created for signing Android release builds.

---

## 🤖 2. Android Release Generation (.apk & .aab)

### A. Setup Signing Keystore
1. Generate a upload keystore (if not already done):
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` file with credentials:
   ```properties
   storePassword=<YOUR_KEYSTORE_PASSWORD>
   keyPassword=<YOUR_KEY_PASSWORD>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

### B. Build Commands

#### 1. Universal Release APK (Direct Install on Devices)
```bash
flutter build apk --release --split-per-abi
```
> **Output Path**: `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` & `app-arm64-v8a-release.apk`

#### 2. Android App Bundle (.aab) - Required for Google Play Store Upload
```bash
flutter build appbundle --release
```
> **Output Path**: `build/app/outputs/bundle/release/app-release.aab`

---

## 🍎 3. iOS Release Generation (.ipa)

### A. Xcode Configuration
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select target **Runner** -> **Signing & Capabilities**.
3. Choose your **Development Team** and verify Provisioning Profiles.

### B. Build Command
```bash
flutter build ipa --release
```
> **Output Path**: `build/ios/archive/Runner.xcarchive` & `build/ios/ipa/`

---

## 📦 4. Verification & Testing Checklist

- [x] Run `flutter analyze` to confirm 0 compilation errors.
- [x] Test release APK on physical Android device (`flutter install`).
- [x] Confirm app permissions in `AndroidManifest.xml` (Internet, Storage, Camera).
- [x] Confirm `google_fonts`, `video_player`, and `path_provider` local caching work in offline mode.
- [x] Upload `.aab` file to **Google Play Console** -> Production / Internal Testing.

---

## 💡 Support & Troubleshooting

- **Proguard / R8 Shrinking Issues**: Ensure `android/app/proguard-rules.pro` excludes swagger and riverpod generated models.
- **Clear Build Cache**:
  ```bash
  flutter clean
  flutter pub get
  ```
