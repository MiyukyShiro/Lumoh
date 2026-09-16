#!/usr/bin/env bash
# Richtet das erzeugte Android-Projekt fertig fuer den Play Store ein:
# Icons, Berechtigungen, Versionsnummern und Signatur.
set -e
APP=android/app
[ -d "$APP" ] || { echo "Kein Android-Projekt. Erst 'npx cap add android' laufen lassen."; exit 1; }

echo "→ Icons einsetzen"
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi anydpi-v26; do
  mkdir -p "$APP/src/main/res/mipmap-$d"
  cp -f android-res/mipmap-$d/* "$APP/src/main/res/mipmap-$d/" 2>/dev/null || true
done
mkdir -p "$APP/src/main/res/values"
cp -f android-res/values/colors.xml "$APP/src/main/res/values/colors.xml"

echo "→ Berechtigungen eintragen"
M="$APP/src/main/AndroidManifest.xml"
for P in ACTIVITY_RECOGNITION POST_NOTIFICATIONS SCHEDULE_EXACT_ALARM; do
  grep -q "$P" "$M" || sed -i.bak "s|<application|<uses-permission android:name=\"android.permission.$P\" />\n\n    <application|" "$M"
done
# Standort ist optional: nur abfragen, nicht als Pflicht verlangen
grep -q "android.hardware.location" "$M" || sed -i.bak \
  "s|<application|<uses-feature android:name=\"android.hardware.location.gps\" android:required=\"false\" />\n\n    <application|" "$M"
rm -f "$M.bak"

echo "→ Version setzen"
V_NAME="${LUMO_VERSION_NAME:-1.11.0}"
V_CODE="${LUMO_VERSION_CODE:-11}"
sed -i "s/versionCode .*/versionCode $V_CODE/; s/versionName .*/versionName \"$V_NAME\"/" "$APP/build.gradle"

echo "→ Signatur einrichten"
if [ -f "$APP/lumo-upload.keystore" ] && [ -n "$LUMO_KEY_ALIAS" ]; then
  if ! grep -q "signingConfigs" "$APP/build.gradle"; then
    python3 - "$APP/build.gradle" <<'PY'
import sys, re
p = sys.argv[1]; s = open(p, encoding="utf-8").read()
block = '''    signingConfigs {
        release {
            storeFile file("lumo-upload.keystore")
            storePassword System.getenv("LUMO_STORE_PASSWORD")
            keyAlias System.getenv("LUMO_KEY_ALIAS")
            keyPassword System.getenv("LUMO_KEY_PASSWORD")
        }
    }
'''
s = s.replace("android {", "android {\n" + block, 1)
s = re.sub(r'(buildTypes\s*\{\s*release\s*\{)',
           r'\1\n            signingConfig signingConfigs.release',
           s, count=1)
open(p, "w", encoding="utf-8").write(s)
print("   build.gradle ergaenzt")
PY
  fi
else
  echo "   (kein Schluessel gefunden – es wird unsigniert gebaut)"
fi
echo "Fertig."
