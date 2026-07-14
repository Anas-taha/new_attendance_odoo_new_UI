# HR Attendance Odoo — monorepo

White-label HR mobile apps backed by Odoo.

## Layout

- [`packages/hr_core`](packages/hr_core) — shared Flutter package (UI, API, routing)
- [`apps/bluehr`](apps/bluehr), [`apps/alshalawi`](apps/alshalawi), [`apps/smartfitness`](apps/smartfitness) — company app shells
- [`docs/WHITE_LABEL.md`](docs/WHITE_LABEL.md) — how to add a company, sign, and ship

## Quick start

```powershell
cd apps/bluehr
flutter pub get
flutter run
```

## New company

```powershell
.\tool\new_company.ps1 -Slug acme -AppName "ACME HR" -ApplicationId com.acme.hr `
  -OdooBaseUrl "https://example.com/mobile/" -OdooDatabase acme_db -PrimaryColor 670379
```

See [docs/WHITE_LABEL.md](docs/WHITE_LABEL.md) for signing, icons, and store upload.
