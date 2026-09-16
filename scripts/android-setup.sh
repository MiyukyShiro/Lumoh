#!/usr/bin/env bash
# Richtet das erzeugte Android-Projekt fertig ein: Icons, Berechtigungen, Version, Signatur.
# Bricht laut ab, wenn etwas fehlt – stilles Durchrutschen hat schon einmal
# eine APK mit den grauen Standard-Icons erzeugt.
set -euo pipefail
APP=android/app
RES="$APP/src/main/res"

[ -d "$APP" ]        || { echo "FEHLER: Kein Android-Projekt. Erst 'npx cap add android'."; exit 1; }
[ -d android-res ]   || { echo "FEHLER: Ordner 'android-res' fehlt im Repository. Ohne ihn gibt es keine Lumo-Icons."; exit 1; }

echo "→ Icons einsetzen"
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi anydpi-v26; do
  [ -d "android-res/mipmap-$d" ] || { echo "FEHLER: android-res/mipmap-$d fehlt."; exit 1; }
  mkdir -p "$RES/mipmap-$d"
  cp -f android-res/mipmap-$d/* "$RES/mipmap-$d/"
done
mkdir -p "$RES/values"
cp -f android-res/values/colors.xml "$RES/values/colors.xml"
# Capacitors Standard-Hintergrund entfernen, damit nichts mehr danebengreift
rm -f "$RES/drawable/ic_launcher_background.xml" "$RES/drawable-v24/ic_launcher_foreground.xml" 2>/dev/null || true

# Gegenprobe: liegen unsere Dateien wirklich da?
for f in "$RES/mipmap-xxxhdpi/ic_launcher.png" "$RES/mipmap-xxxhdpi/ic_launcher_background.png" \
         "$RES/mipmap-anydpi-v26/ic_launcher.xml"; do
  [ -f "$f" ] || { echo "FEHLER: $f wurde nicht angelegt."; exit 1; }
done
grep -q "@mipmap/ic_launcher_background" "$RES/mipmap-anydpi-v26/ic_launcher.xml" \
  || { echo "FEHLER: Adaptive Icon zeigt nicht auf unseren Hintergrund."; exit 1; }
echo "   Icons sitzen."

echo "→ Berechtigungen eintragen"
M="$APP/src/main/AndroidManifest.xml"
for P in ACTIVITY_RECOGNITION POST_NOTIFICATIONS SCHEDULE_EXACT_ALARM; do
  grep -q "$P" "$M" || sed -i.bak "s|<application|<uses-permission android:name=\"android.permission.$P\" />\n\n    <application|" "$M"
done
grep -q "android.hardware.location" "$M" || sed -i.bak \
  "s|<application|<uses-feature android:name=\"android.hardware.location.gps\" android:required=\"false\" />\n\n    <application|" "$M"
rm -f "$M.bak"

echo "→ Version setzen"
V_NAME="${LUMO_VERSION_NAME:-1.17.0}"
V_CODE="${LUMO_VERSION_CODE:-17}"
sed -i "s/versionCode .*/versionCode $V_CODE/; s/versionName .*/versionName \"$V_NAME\"/" "$APP/build.gradle"

echo "→ Signatur einrichten"
if [ -f "$APP/lumo-upload.keystore" ] && [ -n "${LUMO_KEY_ALIAS:-}" ]; then
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
s = re.sub(r'(buildTypes\s*\{\s*release\s*\{)', r'\1\n            signingConfig signingConfigs.release', s, count=1)
open(p, "w", encoding="utf-8").write(s)
print("   build.gradle ergaenzt")
PY
  fi
else
  echo "   (kein Schluessel hinterlegt – es wird mit dem Debug-Schluessel gebaut)"
fi
echo "Einrichtung fertig."
