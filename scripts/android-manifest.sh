#!/usr/bin/env bash
# Ergaenzt die Berechtigung fuer den Schrittzaehler (Android 10+).
set -e
M="android/app/src/main/AndroidManifest.xml"
[ -f "$M" ] || { echo "AndroidManifest nicht gefunden — erst 'npx cap add android' laufen lassen."; exit 1; }
for P in ACTIVITY_RECOGNITION POST_NOTIFICATIONS SCHEDULE_EXACT_ALARM; do
  grep -q "$P" "$M" || sed -i.bak "s|<application|<uses-permission android:name=\"android.permission.$P\" />\n\n    <application|" "$M"
done
echo "AndroidManifest ergaenzt."
