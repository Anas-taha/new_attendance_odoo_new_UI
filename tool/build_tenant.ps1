param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("bluehr", "alshalawi", "smartfitness")]
    [string]$Tenant,

    [ValidateSet("run", "apk", "appbundle")]
    [string]$Target = "apk"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$ConfigFile = Join-Path $Root "tenants\$Tenant.json"
if (-not (Test-Path $ConfigFile)) {
    throw "Missing tenant config: $ConfigFile"
}

$FlavorArgs = @("--flavor", $Tenant, "--dart-define-from-file=$ConfigFile")

switch ($Target) {
    "run" {
        flutter run @FlavorArgs
    }
    "apk" {
        flutter build apk --release @FlavorArgs
    }
    "appbundle" {
        flutter build appbundle --release @FlavorArgs
    }
}

Write-Host "Done. Tenant=$Tenant Target=$Target"
