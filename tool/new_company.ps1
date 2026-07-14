param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [Parameter(Mandatory = $true)]
    [string]$ApplicationId,

    [Parameter(Mandatory = $true)]
    [string]$OdooBaseUrl,

    [Parameter(Mandatory = $true)]
    [string]$OdooDatabase,

    [Parameter(Mandatory = $true)]
    [string]$PrimaryColor,

    [Parameter(Mandatory = $true)]
    [string]$SecondaryColor
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Template = Join-Path $Root "apps\_template"
$Target = Join-Path $Root "apps\$Slug"

if (-not (Test-Path $Template)) {
    throw "Missing template folder: $Template"
}

if (Test-Path $Target) {
    throw "App already exists: $Target"
}

Write-Host "Creating app shell at $Target ..."
robocopy $Template $Target /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null

$replacements = @{
    "{{APP_SLUG}}" = $Slug
    "{{APP_NAME}}" = $AppName
    "{{APPLICATION_ID}}" = $ApplicationId
    "{{ODOO_BASE_URL}}" = $OdooBaseUrl
    "{{ODOO_DATABASE}}" = $OdooDatabase
    "{{PRIMARY_COLOR}}" = $PrimaryColor.TrimStart('#')
    "{{SECONDARY_COLOR}}" = $SecondaryColor.TrimStart('#')
}

$files = Get-ChildItem -Path $Target -Recurse -File | Where-Object {
    $_.Extension -in '.dart', '.yaml', '.xml', '.plist', '.kts', '.gradle', '.properties', '.json'
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    foreach ($key in $replacements.Keys) {
        $content = $content.Replace($key, $replacements[$key])
    }
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
}

Push-Location $Target
flutter pub get
if (Test-Path "assets\branding\app_icon.png") {
    dart run flutter_launcher_icons
}
Pop-Location

Write-Host ""
Write-Host "Created apps/$Slug"
Write-Host "Next steps:"
Write-Host "  1. Replace assets/branding/app_icon.png and logo.png with company artwork"
Write-Host "  2. Run: cd apps/$Slug; dart run flutter_launcher_icons"
Write-Host "  3. Create android/key.properties + release keystore for this app"
Write-Host "  4. Open ios/Runner.xcworkspace in Xcode, set Team + signing for bundle id $ApplicationId"
Write-Host "  5. Build: cd apps/$Slug; flutter build appbundle --release"
