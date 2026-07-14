# White-label / multi-company distribution

Each company gets its **own Play Store / App Store listing** as a separate Flutter app that depends on the shared [`hr_core`](../packages/hr_core) package.

## Architecture

```
packages/hr_core/          Shared UI, services, routing, theme, l10n, assets
apps/
  bluehr/                  Standalone app (own android/, ios/, signing, bundle id)
  alshalawi/
  smartfitness/
  _template/               Copy scaffold for new companies
tool/new_company.ps1       Creates apps/<slug> from _template
```

Each app shell is thin: `lib/main.dart` constructs a `TenantConfig` and calls `runHrCoreApp()`.

```dart
import 'package:flutter/material.dart';
import 'package:hr_core/hr_core.dart';

void main() {
  runHrCoreApp(
    config: const TenantConfig(
      appName: 'ALSHALAWI',
      odooBaseUrl: 'https://al-shalawi.gulftriangle.net/mobile/',
      odooDatabase: 'al-shalawi',
      primaryColor: Color(0xFF670379),
      secondaryColor: Color(0xFF89734e),
      logoAssetPath: 'assets/branding/logo.png',
    ),
  );
}
```

## What differs per company

| Item | Where to configure |
|------|-------------------|
| Play Store / App Store listing | Separate app per `applicationId` / bundle ID in `apps/<slug>/` |
| App name (launcher) | `android/.../strings.xml`, `ios/Runner/Info.plist`, `TenantConfig.appName` |
| Odoo server URL | `TenantConfig.odooBaseUrl` in `lib/main.dart` |
| Odoo database | `TenantConfig.odooDatabase` in `lib/main.dart` |
| Primary brand color | `TenantConfig.primaryColor` in `lib/main.dart` (app bar, accents) |
| Button color | `TenantConfig.secondaryColor` in `lib/main.dart` (ElevatedButton, CustomButton) |
| App icon | `assets/branding/app_icon.png` + `flutter_launcher_icons.yaml` |
| In-app logo (optional) | `assets/branding/logo.png` + `TenantConfig.logoAssetPath` |
| Android signing | `android/key.properties` + `.jks` keystore (per app, gitignored) |
| iOS signing | Xcode → Signing & Capabilities (per app, own team/provisioning) |

Shared icons (attendance, calendar, etc.) live in `packages/hr_core/assets/` and are loaded via `AppImage` using `packages/hr_core/...` paths.

## Run / build a company app

```powershell
cd apps/alshalawi
flutter pub get
flutter run
flutter build apk --release
flutter build appbundle --release
```

VS Code: use launch configs **bluehr**, **alshalawi**, or **smartfitness** (each points at its app folder).

### Wrong launcher icon after copying a shell?

Android adaptive icons use `drawable-*/ic_launcher_foreground.png` (and legacy `mipmap-*/ic_launcher_foreground.png`). If an app was copied from another shell, those PNGs may still be the **previous company's icon** even when `assets/branding/app_icon.png` is correct.

Fix:

```powershell
cd apps/alshalawi
dart run flutter_launcher_icons
flutter clean
flutter run
```

Uninstall the old APK from the device first if the home-screen icon is cached.

## Add a new company

```powershell
.\tool\new_company.ps1 `
  -Slug acme `
  -AppName "ACME HR" `
  -ApplicationId com.acme.hr `
  -OdooBaseUrl "https://your-odoo-server.com/mobile/" `
  -OdooDatabase your_odoo_database `
  -PrimaryColor 670379 `
  -SecondaryColor 89734e
```

Then:

1. Replace `apps/acme/assets/branding/app_icon.png` and `logo.png`
2. `cd apps/acme; dart run flutter_launcher_icons` (required — copies from `_template` still carry the old launcher PNGs until you regenerate)
3. Create Android release keystore + `android/key.properties` (see below)
4. Open `apps/acme/ios/Runner.xcworkspace` in Xcode → set Team and bundle id
5. Build and upload AAB/IPA as a **new** store listing

## Android signing (per app)

Create a keystore (once per company):

```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `apps/<slug>/android/key.properties` (do **not** commit):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=../upload-keystore.jks
```

Each app's `android/app/build.gradle.kts` already reads `key.properties` when present and falls back to debug signing otherwise.

## iOS (per app)

Each `apps/<slug>/ios/` is a normal single-target Xcode project:

1. Open `Runner.xcworkspace` in Xcode
2. Set **Team** under Signing & Capabilities
3. Confirm `PRODUCT_BUNDLE_IDENTIFIER` matches the company's bundle id
4. Build: `flutter build ipa --release` from the app directory

## CI matrix example

Build one job per company app:

```yaml
strategy:
  matrix:
    app: [bluehr, alshalawi, smartfitness]
steps:
  - run: cd apps/${{ matrix.app }} && flutter pub get
  - run: cd apps/${{ matrix.app }} && flutter analyze
  - run: cd apps/${{ matrix.app }} && flutter build appbundle --release
```

Use separate signing credentials per client when they own their store accounts.

## Store accounts

- **You publish all apps**: one Google Play / Apple developer account, many apps (different bundle IDs).
- **Each company publishes their own**: give them the signed AAB/IPA + store assets; they upload under their account.

## Updating shared features

Change code in `packages/hr_core/`. All company apps pick it up on the next `flutter pub get` / build (path dependency). Bump `hr_core` version when publishing via private Git instead of path deps.
