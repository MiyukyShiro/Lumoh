#!/usr/bin/env bash
# Richtet das Android-Projekt ein: Icons, Berechtigungen, Version, Signatur.
# Meldet Probleme laut, bricht den Build aber nicht ab – eine App mit
# Standard-Icon ist besser als gar keine.
set -uo pipefail
APP=android/app
RES="$APP/src/main/res"
ICON_OK=nein

echo "══════════════════════════════════════════════"
echo " Lumo – Android einrichten"
echo "══════════════════════════════════════════════"

if [ ! -d "$APP" ]; then
  echo "ABBRUCH: Kein Android-Projekt gefunden. Lief 'npx cap add android' durch?"
  exit 1
fi

echo "→ Icons"
if [ ! -d android-res ]; then
  echo "   !!! Ordner 'android-res' fehlt im Repository."
  echo "   !!! Die App bekommt deshalb Capacitors graue Standard-Icons."
  echo "   !!! Lade den Ordner 'android-res' mit hoch, dann sitzt Lumo drauf."
  echo "   Inhalt des Projektordners zum Vergleich:"
  ls -1 | sed 's/^/     /'
else
  fehlt=nein
  for d in mdpi hdpi xhdpi xxhdpi xxxhdpi anydpi-v26; do
    if [ -d "android-res/mipmap-$d" ] && [ -n "$(ls -A android-res/mipmap-$d 2>/dev/null)" ]; then
      mkdir -p "$RES/mipmap-$d"
      cp -f android-res/mipmap-$d/* "$RES/mipmap-$d/" && echo "   mipmap-$d übernommen"
    else
      echo "   !!! android-res/mipmap-$d ist leer oder fehlt"; fehlt=ja
    fi
  done
  if [ -f android-res/values/colors.xml ]; then
    mkdir -p "$RES/values"; cp -f android-res/values/colors.xml "$RES/values/colors.xml"
  fi
  rm -f "$RES/drawable/ic_launcher_background.xml" 2>/dev/null
  if [ "$fehlt" = "nein" ] && [ -f "$RES/mipmap-xxxhdpi/ic_launcher_background.png" ] \
     && grep -q "@mipmap/ic_launcher_background" "$RES/mipmap-anydpi-v26/ic_launcher.xml" 2>/dev/null; then
    ICON_OK=ja
    echo "   ✓ Lumo-Icons sitzen"
  else
    echo "   !!! Icons unvollständig – es bleiben die Standard-Icons"
  fi
fi
echo "$ICON_OK" > .icon-status

echo "→ Berechtigungen"
M="$APP/src/main/AndroidManifest.xml"
if [ -f "$M" ]; then
  for P in ACTIVITY_RECOGNITION POST_NOTIFICATIONS SCHEDULE_EXACT_ALARM; do
    grep -q "$P" "$M" || sed -i.bak "s|<application|<uses-permission android:name=\"android.permission.$P\" />\n\n    <application|" "$M"
  done
  grep -q "android.hardware.location" "$M" || sed -i.bak \
    "s|<application|<uses-feature android:name=\"android.hardware.location.gps\" android:required=\"false\" />\n\n    <application|" "$M"
  rm -f "$M.bak"
  echo "   ✓ eingetragen"
fi

echo "→ Version"
G="$APP/build.gradle"
if [ -f "$G" ]; then
  sed -i "s/versionCode .*/versionCode ${LUMO_VERSION_CODE:-17}/; s/versionName .*/versionName \"${LUMO_VERSION_NAME:-1.17.0}\"/" "$G"
  grep -E "versionCode|versionName" "$G" | sed 's/^/     /'
fi

echo "→ Signatur"
if [ -f "$APP/lumo-upload.keystore" ] && [ -n "${LUMO_KEY_ALIAS:-}" ] && ! grep -q signingConfigs "$G"; then
  python3 - "$G" <<'PY'
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
print("     build.gradle ergaenzt")
PY
else
  echo "     (Debug-Schlüssel)"
fi
echo "══════════════════════════════════════════════"
echo " Icons von Lumo: $ICON_OK"
echo "══════════════════════════════════════════════"
exit 0
