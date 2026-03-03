# Bid app

Flutter + Firebase mobile app.

## Release Metadata

- iOS Bundle Identifier: `com.bidapp.hal`
- App Display Name: `Bid app`
- Version Name: `1.0.0`
- Build Number: `1`

## Baseline Commands

```bash
flutter --version
flutter pub get
dart format .
flutter analyze
flutter test
```

## iOS Release Prep

1. Ensure macOS + Xcode are available (iOS builds cannot run on Windows).
2. Install CocoaPods:
   - `sudo gem install cocoapods` (or Homebrew equivalent)
3. Run:
   - `cd ios && pod install && cd ..`
4. Validate release compile:
   - `flutter clean`
   - `flutter pub get`
   - `flutter build ios --release --no-codesign`

## Firebase iOS Requirements

1. Add `ios/Runner/GoogleService-Info.plist` for iOS app id `com.bidapp.hal`.
2. Regenerate FlutterFire config after changing bundle id:
   - `flutterfire configure --platforms=ios,android,web`
3. Verify Crashlytics dSYM upload in Xcode build phase after adding Crashlytics SDK.
4. If push notifications are used:
   - Enable Push Notifications capability in Runner target.
   - Enable Background Modes > Remote notifications.
   - Upload APNs key in Firebase Console.

## TestFlight Upload

### Option A: Xcode

1. Open `ios/Runner.xcworkspace`.
2. Select `Runner` target and set Signing Team (Automatic Signing).
3. Product > Archive.
4. Validate archive.
5. Distribute App > App Store Connect > TestFlight.

### Option B: Fastlane (recommended)

Add lanes in `ios/fastlane/Fastfile`:

- `lint_test`: run `flutter analyze` and `flutter test`
- `build_ios`: run `flutter build ios --release --no-codesign`
- `beta`: upload build to TestFlight (`pilot`)

Required env vars:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_CONTENT`

## App Store Connect Checklist

- Privacy Policy URL: `{PRIVACY_POLICY_URL}`
- Support URL: `{SUPPORT_URL}`
- Demo account credentials: `{DEMO_LOGIN}`
- App description + keywords
- Screenshots for all required device sizes
- 1024x1024 app icon
- Reviewer notes with any special login/payment steps
