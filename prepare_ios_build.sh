#!/usr/bin/env bash
# Prepare an app shell for iOS (pub get → pod install → config-only release build).
#
# Usage:
#   ./prepare_ios_build.sh                  # default: bluehr
#   ./prepare_ios_build.sh smartfitness
#   ./prepare_ios_build.sh alshalawi
#   ./prepare_ios_build.sh all              # run for every company app

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ARG="${1:-bluehr}"
APPS=(bluehr alshalawi smartfitness)

prepare_app() {
  local app="$1"
  local app_dir="$ROOT_DIR/apps/$app"
  local ios_dir="$app_dir/ios"

  if [[ ! -d "$app_dir" ]]; then
    echo "❌ App not found: apps/$app"
    exit 1
  fi

  echo "========================================"
  echo " Preparing iOS: $app"
  echo "========================================"
  echo

  echo "1) flutter pub get"
  (
    cd "$app_dir"
    flutter pub get
  )
  echo

  echo "2) pod install"
  (
    cd "$ios_dir"
    pod install
  )
  echo

  echo "3) flutter build ios --config-only --release"
  (
    cd "$app_dir"
    flutter build ios --config-only --release
  )
  echo

  echo "✅ $app is ready for Xcode / IPA build"
  echo "   Open: apps/$app/ios/Runner.xcworkspace"
  echo "   Or:   cd apps/$app && flutter build ipa --release"
  echo
}

if [[ "$APP_ARG" == "all" ]]; then
  for app in "${APPS[@]}"; do
    prepare_app "$app"
  done
elif [[ " ${APPS[*]} " == *" $APP_ARG "* ]]; then
  prepare_app "$APP_ARG"
else
  echo "Usage: $0 [bluehr|alshalawi|smartfitness|all]"
  exit 1
fi
