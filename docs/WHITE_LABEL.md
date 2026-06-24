# White-label / multi-company distribution

Each company gets its **own Play Store / App Store listing** by building a separate flavor with a unique bundle ID, app name, icon, and Odoo server.

## Architecture

```
tenants/
  bluehr.json          # Company A config
  alshalawi.json       # Company B config
  smartfitness.json    # Smart Fitness config
  template.json        # Copy this for new companies

lib/config/
  tenant_config.dart   # Reads compile-time values from JSON
  odoo_config.dart     # Uses TenantConfig for API URL + database
```

Build command injects tenant settings at compile time:

```powershell
flutter build appbundle --release --flavor alshalawi --dart-define-from-file=tenants/alshalawi.json
flutter build apk --release --flavor smartfitness --dart-define-from-file=tenants/smartfitness.json
flutter build appbundle --release --flavor smartfitness --dart-define-from-file=tenants/smartfitness.json
```

Or use the helper script:

```powershell
.\tool\build_tenant.ps1 -Tenant alshalawi -Target appbundle
.\tool\build_tenant.ps1 -Tenant smartfitness -Target apk
.\tool\build_tenant.ps1 -Tenant bluehr -Target run
```

## What differs per company (store requirement)

| Item | Where to configure |
|------|-------------------|
| Play Store / App Store listing | Separate app per `applicationId` / bundle ID |
| App name (launcher) | `tenants/*.json` → `APP_NAME` + Android `productFlavors.resValue` |
| Odoo server URL | `ODOO_BASE_URL` in tenant JSON |
| Odoo database | `ODOO_DATABASE` in tenant JSON |
| Primary brand color | `PRIMARY_COLOR` in tenant JSON |
| App icon | `android/app/src/<flavor>/res/mipmap-*` (per flavor) |
| iOS icon / name | Xcode scheme + `Info.plist` per tenant (see below) |

## Add a new company

1. Copy `tenants/template.json` → `tenants/acme.json`
2. Fill in `APP_NAME`, `APPLICATION_ID`, `ODOO_BASE_URL`, `ODOO_DATABASE`
3. Add Android flavor in `android/app/build.gradle.kts`:

```kotlin
create("acme") {
    dimension = "tenant"
    applicationId = "com.acme.hr"
    resValue("string", "app_name", "ACME HR")
}
```

4. Add launcher icons under `android/app/src/acme/res/mipmap-*`
5. (iOS) Duplicate Runner scheme → `acme`, set `PRODUCT_BUNDLE_IDENTIFIER`
6. Build: `.\tool\build_tenant.ps1 -Tenant acme -Target appbundle`
7. Upload the AAB/IPA to Play Console / App Store Connect as a **new app**

## iOS (one listing per company)

1. Open `ios/Runner.xcworkspace`
2. Duplicate the `Runner` scheme → name it after the tenant (e.g. `alshalawi`)
3. Create `.xcconfig` or build configurations with unique `PRODUCT_BUNDLE_IDENTIFIER`
4. Build:

```bash
flutter build ipa --flavor alshalawi --dart-define-from-file=tenants/alshalawi.json
```

## CI matrix (Codemagic / GitHub Actions)

Run one job per tenant:

```yaml
strategy:
  matrix:
    tenant: [bluehr, alshalawi, smartfitness]
steps:
  - run: flutter build appbundle --release --flavor ${{ matrix.tenant }} --dart-define-from-file=tenants/${{ matrix.tenant }}.json
```

Use separate signing credentials per client if they own their store accounts.

## Store accounts

- **You publish all apps**: one Google Play / Apple developer account, many apps (different bundle IDs).
- **Each company publishes their own**: export signed AAB/IPA + give them store assets; they upload under their account.
