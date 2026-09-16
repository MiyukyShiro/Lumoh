#!/usr/bin/env bash
# Trägt die Berechtigungstexte und den Hintergrund-Audio-Modus in die Info.plist ein.
# Nach jedem "npx cap add ios" einmal ausführen.
set -e
P="ios/App/App/Info.plist"
[ -f "$P" ] || { echo "Info.plist nicht gefunden — erst 'npx cap add ios' laufen lassen."; exit 1; }
B=/usr/libexec/PlistBuddy

set_str () { $B -c "Delete :$1" "$P" 2>/dev/null || true; $B -c "Add :$1 string $2" "$P"; }

set_str NSMotionUsageDescription "Lumo zählt deine Schritte, um Bewegung in die Stimmungsauswertung einzubeziehen."
set_str NSLocationWhenInUseUsageDescription "Für das lokale Wetter, das in deine Stimmungsauswertung einfliesst."
set_str NSMicrophoneUsageDescription "Für das Sprach-Tagebuch. Die Aufnahme verlaesst dein Geraet nicht."
set_str NSSpeechRecognitionUsageDescription "Wandelt dein gesprochenes Tagebuch in Text um."

# Musik laeuft bei gesperrtem Bildschirm weiter
$B -c "Delete :UIBackgroundModes" "$P" 2>/dev/null || true
$B -c "Add :UIBackgroundModes array" "$P"
$B -c "Add :UIBackgroundModes:0 string audio" "$P"

echo "Info.plist ergaenzt."
