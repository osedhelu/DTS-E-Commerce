#!/usr/bin/env bash
# Tras activar Authentication → Google en Firebase (dtsdrop-85330),
# regenera google-services.json / GoogleService-Info.plist y el URL scheme iOS.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRV_ANDROID="1:1015036938407:android:041cc4084dd2a93008b382"
DRV_IOS="1:1015036938407:ios:659a99afcda1b3cf08b382"
TMP="$(mktemp -d)"

cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "==> Descargando SDK configs dtsdrop (DTS Driver)…"
firebase apps:sdkconfig ANDROID "$DRV_ANDROID" --project dtsdrop-85330 -o "$TMP/gs.json"
firebase apps:sdkconfig IOS "$DRV_IOS" --project dtsdrop-85330 -o "$TMP/GoogleService-Info.plist"

python3 - <<PY
import json, plistlib, re
from pathlib import Path

root = Path("$ROOT")
tmp = Path("$TMP")

gs = json.loads((tmp / "gs.json").read_text())
gs["client"] = [
    c for c in gs["client"]
    if c["client_info"]["android_client_info"]["package_name"] == "com.osedhelu.dtsdriver"
]
(root / "flutter-driver/android/app/google-services.json").write_text(
    json.dumps(gs, indent=2) + "\n"
)
oauth = gs["client"][0].get("oauth_client", []) if gs["client"] else []
print(f"android oauth_client count: {len(oauth)}")
print(f"android has type1: {any(o.get('client_type') == 1 for o in oauth)}")

pl = plistlib.loads((tmp / "GoogleService-Info.plist").read_bytes())
(root / "flutter-driver/ios/Runner/GoogleService-Info.plist").write_bytes(plistlib.dumps(pl))
print("ios CLIENT_ID:", "CLIENT_ID" in pl)
print("ios REVERSED_CLIENT_ID:", "REVERSED_CLIENT_ID" in pl)

info = root / "flutter-driver/ios/Runner/Info.plist"
text = info.read_text()
reversed_id = pl.get("REVERSED_CLIENT_ID")
client_id = pl.get("CLIENT_ID")
if reversed_id:
    # Upsert CFBundleURLTypes with REVERSED_CLIENT_ID
    block = f'''\t<key>CFBundleURLTypes</key>
\t<array>
\t\t<dict>
\t\t\t<key>CFBundleTypeRole</key>
\t\t\t<string>Editor</string>
\t\t\t<key>CFBundleURLSchemes</key>
\t\t\t<array>
\t\t\t\t<string>{reversed_id}</string>
\t\t\t</array>
\t\t</dict>
\t</array>
'''
    if "<key>CFBundleURLTypes</key>" in text:
        text = re.sub(
            r"\t<key>CFBundleURLTypes</key>.*?</array>\n",
            block,
            text,
            count=1,
            flags=re.S,
        )
    else:
        text = text.replace("</dict>\n</plist>", block + "</dict>\n</plist>")
    if client_id:
        if "<key>GIDClientID</key>" in text:
            text = re.sub(
                r"<key>GIDClientID</key>\s*<string>[^<]*</string>",
                f"<key>GIDClientID</key>\n\t<string>{client_id}</string>",
                text,
                count=1,
            )
        else:
            text = text.replace(
                "\t<key>CFBundleURLTypes</key>",
                f"\t<key>GIDClientID</key>\n\t<string>{client_id}</string>\n\t<key>CFBundleURLTypes</key>",
            )
        print("Info.plist GIDClientID updated")
    info.write_text(text)
    print("Info.plist URL scheme updated")
else:
    print("WARN: sin REVERSED_CLIENT_ID — activa Google Sign-In en Firebase Console primero")
    raise SystemExit(2)

# Patch firebase_options.dart iosClientId if CLIENT_ID present
fo = root / "flutter-driver/lib/firebase_options.dart"
src = fo.read_text()
if client_id and "iosClientId" not in src:
    src = src.replace(
        f"iosBundleId: 'com.osedhelu.dtsdriver',",
        f"iosBundleId: 'com.osedhelu.dtsdriver',\n    iosClientId: '{client_id}',",
    )
    fo.write_text(src)
    print("firebase_options.dart iosClientId added")
elif client_id:
    src = re.sub(
        r"iosClientId:\s*'[^']*',",
        f"iosClientId: '{client_id}',",
        src,
    )
    fo.write_text(src)
    print("firebase_options.dart iosClientId updated")
PY

echo "==> Listo. Rebuild:"
echo "    cd flutter-driver && flutter run --release"
