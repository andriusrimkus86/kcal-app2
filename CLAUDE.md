# Kalorijų žurnalas (kcal tracker) – project notes for Claude Code

Single-file HTML calorie/protein tracker (`www/index.html`, vanilla JS, no build step) wrapped as an Android APK with Capacitor 6.2.0.
Owner speaks Lithuanian and English; UI has an EN/LT switch (`LT` dictionary + `translateDom`). Dark mode, metric units, ISO dates (YYYY-MM-DD).

## Layout
- `www/index.html` – the whole app. State in localStorage key `kcal-log-v1` (`db`), UI state in `ui`, click handlers in the `actions` object (`data-act="..."`), string-template render functions (`render()`, `renderSheet()`). Version label is in `sheetSettings()` ("App version N") – bump it on every change.
- `package.json`, `capacitor.config.json` – Capacitor core/android/cli 6.2.0, local-notifications 6.1.2, @capacitor-mlkit/barcode-scanning 6.2.0, @capacitor/app 6.0.2.
- `.github/workflows/build-apk.yml` – CI. Runs `npx cap add android`, then injects native code with heredocs/sed/python: camera + notification permissions, ML Kit dependency meta-data, home-screen widget (Java + XML, `WidgetBridge.update`), adaptive app icon + PNG mipmap fallbacks. Produces the debug APK artifact.
- `Code.gs` – Google Apps Script web app (no password) for Google Sheet sync. Sheet ID 1rSOpzmaGvdTw4be-eYRTCfj_hNOrQNdDqnvP-r51qwU; tabs "Kalorijos maisto", "Kalendorius", "2026 4Q", "Dienos kcal" (rows 5-22: C product text where value is `>>`, F amount, G unit g/vnt., B checkbox).

## Features (all implemented)
Today log, Calendar, Foods (sort, search without diacritics, recent/favourites, copy yesterday, quick add, barcode scan via native ML Kit + Open Food Facts, auto-fill kcal/protein for new foods), Weight + graph (Y-axis modes, progress bar, BMI chips), Recipes (portions, scaling, notes, "Choose ingredients" custom entries), Recipe ideas, Weekly/Monthly summary (deficit vs maintenance), reminders, widget, back-button double-press exit, Google Sheets sync.
Maintenance/target: `autoGoals()` (called from `save()`) recomputes `goals.maint` and `goals.kcal` from the latest weight when `goals.auto` is on: original Harris-Benedict BMR x activity factor (1.3 matches "Lengvai aktyvus" on raclub.lt, 3095 for 198 cm/114 kg/36 y male), floor; target = round((maint - deficit)/step)*step.

## How to build
Repo: https://github.com/andriusrimkus86/kcal-app2 (branch `main`). Run `.\build-apk.ps1 "message"` from this folder: commits everything, pushes, waits for the "Build APK" run (`gh run watch`), downloads the artifact to `apk\kcal-log.apk` (replaces the old one). On failure it prints the failed log; fix and rerun. Before building: bump "App version N", `node --check` the script, jsdom-test the change.

## Build the APK (details)
Each push to `main` runs the workflow; the APK is the run's `kcal-log-apk` artifact.
Local alternative: needs JDK 17 + Android SDK. `npm i && npx cap add android`, apply the same native edits the workflow performs (run its `run:` steps), `cd android && ./gradlew assembleDebug` -> `android/app/build/outputs/apk/debug/app-debug.apk`.

## Testing
No device here. Verify logic with jsdom (mock `window.Capacitor`, `fetch`, `scrollTo`): load `www/index.html`, seed localStorage `kcal-log-v1`, click `data-act` buttons, assert on DOM/localStorage. Syntax check: extract the big `<script>` and run `node --check`. Screenshots with Playwright Chromium. Camera, notifications, widget, icon, Sheets sync, and the Android build itself can only be tested on the phone.
