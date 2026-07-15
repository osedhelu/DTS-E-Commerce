#!/usr/bin/env bash
# Crea apps Firebase con packages osedhelu y descarga SDK configs.
#
# Cliente   → discorp-4a37b  → com.osedhelu.dts
# Conductor → dtsdrop-85330  → com.osedhelu.dtsdriver
#
# Uso (raíz monorepo):
#   ./scripts/setup-firebase-osedhelu-packages.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHA1_PLAIN="${ANDROID_DEBUG_SHA1:-69f247b9d146aa5268ac8c6e863bcf14a853ffa4}"

ensure_android() {
  local project="$1" display="$2" package="$3"
  if firebase apps:list --project "$project" 2>/dev/null | grep -Fq "$package"; then
    echo "==> OK Android ${package} ya existe en ${project}"
    return 0
  fi
  echo "==> Creando Android ${package} en ${project}..."
  firebase apps:create ANDROID "$display" --package-name "$package" --project "$project"
}

ensure_ios() {
  local project="$1" display="$2" bundle="$3"
  if firebase apps:list --project "$project" 2>/dev/null | grep -Fq "$bundle"; then
    echo "==> OK iOS ${bundle} ya existe en ${project}"
    return 0
  fi
  echo "==> Creando iOS ${bundle} en ${project}..."
  firebase apps:create IOS "$display" --bundle-id "$bundle" --project "$project"
}

app_id_for() {
  local project="$1" platform="$2" identifier="$3"
  firebase apps:list --project "$project" --json 2>/dev/null | python3 -c "
import json, sys
apps = json.load(sys.stdin).get('result', [])
needle = '''${identifier}'''
plat = '''${platform}'''
for a in apps:
    if a.get('platform') != plat:
        continue
    if plat == 'ANDROID' and a.get('packageName') == needle:
        print(a['appId']); break
    if plat == 'IOS' and a.get('bundleId') == needle:
        print(a['appId']); break
"
}

echo "==> Cliente (discorp-4a37b) → com.osedhelu.dts"
ensure_android discorp-4a37b "DTS Customer (osedhelu)" com.osedhelu.dts
ensure_ios     discorp-4a37b "DTS Customer (osedhelu)" com.osedhelu.dts

echo "==> Conductor (dtsdrop-85330) → com.osedhelu.dtsdriver"
ensure_android dtsdrop-85330 "DTS Driver (osedhelu)" com.osedhelu.dtsdriver
ensure_ios     dtsdrop-85330 "DTS Driver (osedhelu)" com.osedhelu.dtsdriver

cust_android="$(app_id_for discorp-4a37b ANDROID com.osedhelu.dts)"
cust_ios="$(app_id_for discorp-4a37b IOS com.osedhelu.dts)"
drv_android="$(app_id_for dtsdrop-85330 ANDROID com.osedhelu.dtsdriver)"
drv_ios="$(app_id_for dtsdrop-85330 IOS com.osedhelu.dtsdriver)"

echo "Customer Android: ${cust_android:-MISSING}"
echo "Customer iOS:     ${cust_ios:-MISSING}"
echo "Driver Android:   ${drv_android:-MISSING}"
echo "Driver iOS:       ${drv_ios:-MISSING}"

if [[ -n "${cust_android}" ]]; then
  firebase apps:android:sha:create "$cust_android" "$SHA1_PLAIN" --project discorp-4a37b || true
  firebase apps:sdkconfig ANDROID "$cust_android" --project discorp-4a37b \
    -o "$ROOT/flutter-customer/android/app/google-services.json"
fi
if [[ -n "${cust_ios}" ]]; then
  firebase apps:sdkconfig IOS "$cust_ios" --project discorp-4a37b \
    -o "$ROOT/flutter-customer/ios/Runner/GoogleService-Info.plist"
fi
if [[ -n "${drv_android}" ]]; then
  firebase apps:android:sha:create "$drv_android" "$SHA1_PLAIN" --project dtsdrop-85330 || true
  firebase apps:sdkconfig ANDROID "$drv_android" --project dtsdrop-85330 \
    -o "$ROOT/flutter-driver/android/app/google-services.json"
fi
if [[ -n "${drv_ios}" ]]; then
  firebase apps:sdkconfig IOS "$drv_ios" --project dtsdrop-85330 \
    -o "$ROOT/flutter-driver/ios/Runner/GoogleService-Info.plist"
fi

echo "==> SDK configs escritos. Siguiente: actualizar firebase_options.dart en cada app."
