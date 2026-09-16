# Lumo — als App

Drei Wege, sortiert nach Aufwand. Alle nutzen dieselbe Datei `docs/index.html`.

---

## Weg 1 — Installierbare Web-App (10 Minuten, kein Programm nötig)

Das Ergebnis ist ein echtes Icon auf dem Startbildschirm, Vollbild ohne Browserleiste,
offline lauffähig. Für die meisten ist das schon die ganze Miete.

1. GitHub-Konto anlegen, **New repository** → Name `mindquest`, **Public**.
2. Den **ganzen Projektordner** hochladen — Struktur unbedingt beibehalten.
3. **Settings → Pages** → Source: `Deploy from a branch`, Branch: `main`, Ordner **`/docs`** → Save.
4. Nach ein bis zwei Minuten steht deine Adresse dort:
   `https://DEINNAME.github.io/mindquest/`
5. Am Handy öffnen:
   - **Android/Chrome:** Menü ⋮ → *App installieren*
   - **iPhone/Safari:** Teilen-Symbol → *Zum Home-Bildschirm*

Ab jetzt funktionieren Schrittzähler, Mikrofon, Sperrbildschirm-Steuerung und Wetter —
die brauchen alle eine `https`-Adresse.

---

## Weg 2 — Echte APK, ohne Android Studio

GitHub baut die App für dich in der Cloud. Auf deinem Rechner musst du nichts installieren.

**Ein GitHub-Konto brauchst du trotzdem** — zum Anlegen des Repositories, zum Starten
des Builds und zum Herunterladen der fertigen Datei. Das ist kostenlos.
Deine Tester brauchen dagegen keins, siehe „Weitergeben ohne Konto" weiter unten.

1. Repository anlegen wie oben, aber **den ganzen Projektordner** hochladen
   (also `docs/`, `resources/`, `scripts/`, `package.json`, `capacitor.config.json`, `.github/`).
2. Reiter **Actions** öffnen → falls gefragt, Workflows aktivieren.
3. Links **„Lumo APK bauen"** wählen → **Run workflow**.
4. Nach etwa fünf Minuten unten bei **Artifacts** die Datei `Lumo-APK` laden.
5. `app-debug.apk` aufs Handy kopieren und öffnen.
   Android fragt einmal nach der Erlaubnis, Apps aus dieser Quelle zu installieren.

Die APK ist mit einem Debug-Schlüssel signiert: gut für dich und Freunde,
nicht für den Play Store. Dafür brauchst du einen eigenen Signaturschlüssel.

### Weitergeben ohne Konto

Artefakte aus Actions kann nur herunterladen, wer bei GitHub angemeldet ist.
Für Freunde und Tester gibt es deshalb den Veröffentlichen-Weg:

*Actions → „Lumo APK bauen" → Run workflow* — dort den Haken bei
**„APK als Download-Link veröffentlichen"** setzen und eine Version eintragen.

Der Build legt danach unter *Releases* einen Eintrag mit der APK an. Diesen Link
kann jeder öffnen und die Datei herunterladen, ohne Konto und ohne Anmeldung:

```
https://github.com/DEINNAME/mindquest/releases/latest
```

Für iPhone-Nutzer bleibt die Webseite der richtige Weg — dort ist ohnehin kein
Konto nötig.

---

## Weg 3 — Lokal bauen (wenn du es selbst in der Hand haben willst)

Vorausgesetzt: [Node.js](https://nodejs.org) und [Android Studio](https://developer.android.com/studio).

```bash
npm run setup        # Capacitor installieren
npm run add:android  # Android-Projekt erzeugen
npm run apk          # APK bauen
```

Die fertige Datei liegt unter `android/app/build/outputs/apk/debug/app-debug.apk`.
Mit `npm run open:android` öffnest du das Projekt stattdessen in Android Studio —
dort läuft es auch direkt auf einem angeschlossenen Handy.

Für den Schrittzähler danach einmal `bash scripts/android-manifest.sh` ausführen.
Für iOS siehe den eigenen Abschnitt weiter unten.

---

## iPhone und iPad

Beides geht — aber Apple macht es umständlicher als Android.

### Weg 1 funktioniert unverändert

GitHub Pages, Safari öffnen, **Teilen → Zum Home-Bildschirm**. Danach eigenes Icon,
Vollbild, offline. Ein paar Besonderheiten:

* Es **muss Safari sein**. Chrome auf dem iPhone kann keine Web-Apps installieren.
* Der Schrittzähler fragt einmal um Erlaubnis, das ist normal und ab iOS 13 Pflicht.
* Musik **stoppt beim Sperren des Bildschirms**. Das ist eine Beschränkung von WebKit,
  kein Fehler. Die App merkt das selbst und sagt es dir.
* Lege dir gelegentlich über *Verlauf → Sicherung speichern* eine Kopie an.

### Weg 2: echte iOS-App (`.ipa`)

Im Projekt liegt ein zweiter Workflow, `ios.yml`. Er läuft auf einem Mac in GitHubs
Cloud, baut die App **ohne Signatur** und legt dir eine `Lumo-unsigned.ipa` bereit.
Starten unter *Actions → Lumo IPA bauen → Run workflow*.

Diese Datei musst du danach selbst signieren — Apple lässt keine unsignierten Apps zu.
Dafür brauchst du keinen Entwicklervertrag, eine normale Apple-ID genügt:

* **[Sideloadly](https://sideloadly.io)** (Windows oder Mac): iPhone anstecken, IPA
  hineinziehen, Apple-ID eintragen, *Start*.
* **[AltStore](https://altstore.io) / SideStore**: signiert ebenfalls mit deiner Apple-ID
  und erneuert die App automatisch über WLAN.

Mit einer kostenlosen Apple-ID läuft die App **sieben Tage**, danach einmal neu signieren.
Mit dem kostenpflichtigen Entwicklerprogramm (99 $/Jahr) sind es zwölf Monate,
und du könntest sie über TestFlight an andere verteilen.

### Was die native App auf iOS besser kann

Der Workflow trägt über `scripts/ios-plist.sh` den Hintergrund-Audio-Modus ein.
Dadurch läuft die Musikreise dort **auch bei gesperrtem Bildschirm weiter** —
genau das, was die Web-App auf dem iPhone nicht schafft.

### Lokal auf einem Mac

```bash
npm i @capacitor/ios@latest
npx cap add ios
bash scripts/ios-plist.sh
npx cap sync ios
npx cap open ios
```

In Xcode oben dein Gerät wählen, unter *Signing & Capabilities* deine Apple-ID
eintragen und auf ▶ drücken. Das ist der bequemste Weg, wenn du einen Mac hast.

### Funktionen im Vergleich

| | iPhone Web-App | iPhone `.ipa` | Android APK |
|---|---|---|---|
| Musik, Quests, Wetter, Speicher | läuft | läuft | läuft |
| Schrittzähler | läuft | läuft | läuft |
| Sprach-Tagebuch | läuft | Plugin nötig | Plugin nötig |
| Musik bei gesperrtem Bildschirm | **nein** | läuft | mit Plugin |
| Installation | drei Tipps | signieren, 7 Tage | direkt, dauerhaft |

---

## So muss das Repository aussehen

```
mindquest/
├─ docs/                     ← GitHub Pages zeigt auf diesen Ordner
│  ├─ index.html             ← die App selbst
│  ├─ sw.js
│  ├─ manifest.webmanifest
│  ├─ icon-192.png
│  ├─ icon-512.png
│  └─ apple-touch-icon.png
├─ resources/
│  ├─ icon.png
│  ├─ icon-foreground.png
│  └─ splash.png
├─ scripts/
│  ├─ ios-plist.sh
│  └─ android-manifest.sh
├─ .github/
│  └─ workflows/
│     ├─ android.yml
│     └─ ios.yml
├─ capacitor.config.json
├─ package.json
└─ README.md
```

**Achtung beim Hochladen:** Windows und macOS blenden Ordner aus, deren Name mit
einem Punkt beginnt — `.github` wird beim Ziehen darum oft stillschweigend
weggelassen. Fehlt der Ordner, gibt es keinen Reiter *Actions* und keine APK.
Lege die beiden Dateien in dem Fall über *Add file → Create new file* an und
tippe den vollen Pfad `.github/workflows/android.yml` in das Namensfeld:
Sobald du einen Schrägstrich tippst, legt GitHub den Ordner selbst an.

**Die Ordner sind Pflicht.** Liegen alle Dateien flach im Hauptverzeichnis,
findet GitHub die Workflows nicht (die müssen in `.github/workflows/` liegen)
und Pages findet keine Startseite.

Beim Hochladen über *Add file → Upload files* kannst du den **kompletten
entpackten Ordner** ins Browserfenster ziehen — GitHub übernimmt die
Unterordner dann automatisch. Einzelne Dateien anzuklicken zerstört die Struktur.

---

## Schritte und Erinnerungen bei geschlossener App

Das kann eine Web-App grundsätzlich nicht — ein Browser läuft nicht weiter,
wenn er zu ist. Die gebaute App kann es. Der Code dafür ist schon drin und
schaltet sich von selbst ein, sobald die passenden Plugins vorhanden sind.

### Erinnerungen

```bash
npm i @capacitor/local-notifications
npx cap sync
```

Danach plant Lumo die tägliche Erinnerung über das Betriebssystem
(`allowWhileIdle`, täglich wiederholt). Sie kommt auch, wenn die App geschlossen
ist. In der Web-Fassung bleibt der Kalendereintrag der zuverlässige Weg.

Android braucht dafür in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

### Schritte des ganzen Tages

Dafür brauchst du Zugriff auf die Gesundheitsdatenbank des Systems:
**Health Connect** auf Android, **HealthKit** auf iOS. Beide liefern auch die
Stunden, in denen die App gar nicht lief.

Die Brücke im Code (`Native.schritte()`) probiert nacheinander die gängigen
Schnittstellen `queryAggregated`, `querySteps` und `getStatisticCollection`
durch und nimmt den ersten Wert, den sie bekommt. Damit passt sie auf die
meisten Health-Plugins, ohne auf eines festgelegt zu sein.

Such im npm-Verzeichnis nach einem aktuell gepflegten Capacitor-Health-Plugin
(die Paketnamen wechseln häufiger als die Schnittstellen) und installiere es:

```bash
npm i <health-plugin>
npx cap sync
```

Berechtigungen: Android braucht `android.permission.ACTIVITY_RECOGNITION`
(setzt `scripts/android-manifest.sh` bereits) sowie die Health-Connect-Freigaben
des Plugins. iOS braucht `NSHealthShareUsageDescription` in der `Info.plist`.

Liefert kein Plugin einen Wert, zählt Lumo weiter selbst über den
Bewegungssensor — dann eben nur, solange die App offen ist. Nichts bricht.

---

## Wetterabhängige Quests

Zehn Wetterlagen mit je zwei bis drei eigenen Quests: Gewitter, Schnee, Nebel,
Regen, Nacht, Hitze, Wind, Frost, Sonne, Grau. Dazu ein Bonus auf XP und Gold
für Draussen-Quests bei hartem Wetter — 35 % bei Gewitter und Schnee, 25 % bei
Regen, Frost, Hitze und Sturm, 20 % nachts. Bei Gewitter, Starkregen oder
Dunkelheit werden gefährliche Draussen-Quests dagegen gar nicht erst vergeben.

---

## In den Google Play Store

Der Play Store verlangt ein **signiertes AAB**, nicht die Debug-APK. Dafür gibt es
den Workflow `play.yml` — er baut beides: das AAB für den Store und eine signierte
APK zum direkten Weitergeben.

### 1. Einmalig einen Schlüssel erzeugen

Auf deinem Rechner (Java muss installiert sein, kommt mit Android Studio mit):

```bash
keytool -genkey -v -keystore lumo-upload.keystore -alias lumo \
        -keyalg RSA -keysize 2048 -validity 10000
```

Du vergibst dabei zwei Passwörter und ein paar Angaben zur Person.
**Bewahre die Datei und die Passwörter gut auf.** Ohne sie kannst du nie wieder
ein Update derselben App hochladen — Google lässt das nicht zu.

Dann in Text umwandeln:

```bash
base64 -w0 lumo-upload.keystore > keystore.txt     # Linux
base64 -i lumo-upload.keystore | tr -d '\n' > keystore.txt   # macOS
certutil -encode lumo-upload.keystore keystore.txt            # Windows
```

### 2. Vier Geheimnisse bei GitHub hinterlegen

*Settings → Secrets and variables → Actions → New repository secret*

| Name | Inhalt |
|---|---|
| `LUMO_KEYSTORE_BASE64` | der ganze Inhalt von `keystore.txt` |
| `LUMO_STORE_PASSWORD` | das Keystore-Passwort |
| `LUMO_KEY_ALIAS` | `lumo` |
| `LUMO_KEY_PASSWORD` | das Schlüssel-Passwort |

### 3. Bauen lassen

*Actions → „Lumo für den Play Store bauen" → Run workflow.*
Dort trägst du Versionsname (z. B. `1.11.0`) und Versionsnummer (`11`) ein.
**Die Versionsnummer muss bei jedem Upload steigen**, sonst lehnt Google ab.

Ergebnis unter *Artifacts*: `app-release.aab` und `app-release.apk`.

### 4. Im Play Console eintragen

1. [play.google.com/console](https://play.google.com/console) — einmalig 25 $ Registrierung.
2. **App erstellen** → Name `Lumo — Sound of My Mind`, Deutsch, kostenlos, App.
3. **Produktionsversion** → das `.aab` hochladen.
4. **Store-Eintrag**: Texte und Grafiken liegen in `store/play-texte.md`,
   Symbol und Grafikbanner in `store/`.
5. **Datenschutzerklärung**: `https://DEINNAME.github.io/mindquest/datenschutz.html`
6. **Datensicherheit**: „Keine Datenerhebung", Verarbeitung nur auf dem Gerät,
   Löschung durch Nutzer möglich. Die genauen Antworten stehen in `store/play-texte.md`.
7. **Inhaltseinstufung**: Fragebogen ausfüllen, ergibt in der Regel PEGI 3.
8. **Screenshots**: mindestens zwei, selbst aufgenommen.

Google prüft neue Entwicklerkonten. Bei Privatpersonen sind derzeit
**zwölf Tester über vierzehn Tage** nötig, bevor die App öffentlich darf —
plane das ein und nutze so lange den internen Testkanal.

### Was das Skript automatisch erledigt

`scripts/android-setup.sh` setzt vor dem Bauen die Adaptive Icons aus `android-res/`
ein, trägt die Berechtigungen nach, markiert GPS als **optional** (sonst filtert
Google Geräte ohne GPS aus), schreibt Versionsname und -nummer und hängt die
Signatur in die `build.gradle`.

---

## Icons austauschen

`resources/icon.png` (1024×1024) und `resources/splash.png` ersetzen, dann:

```bash
npm i -D @capacitor/assets && npx capacitor-assets generate
```

Das erzeugt alle Grössen für Android und iOS automatisch.

---

## Was in der App anders läuft als im Browser

| Funktion | Web-App (Weg 1) | APK (Weg 2/3) |
|---|---|---|
| Musik, Quests, Wetter, Speicher | läuft | läuft |
| Schrittzähler | läuft | läuft |
| Sprach-Tagebuch | läuft | **läuft nicht** — Android-WebViews haben keine Web Speech API |
| Musik bei gesperrtem Bildschirm | meist | braucht einen Vordergrunddienst |
| Schritte der letzten 24 h | nein, nur bei offener App | mit Health-Connect-Plugin möglich |

Die zwei Lücken schliesst du mit je einem Plugin:

```bash
npm i @capacitor-community/speech-recognition   # Sprache
npm i @capacitor-community/keep-awake           # Bildschirm/Audio wach halten
```

Danach `npx cap sync`. Im Code sind die Stellen markiert: `Voice.toggle()`
für die Spracherkennung, `setBackgroundMode()` für die Wiedergabe.

---

## Berechtigungen

Capacitor fragt Standort und Mikrofon automatisch ab, sobald der Code sie nutzt.
Für den Bewegungssensor braucht Android 10+ zusätzlich in
`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

---

Lumo ist ein Selbsthilfe-Werkzeug und ersetzt keine Therapie.
