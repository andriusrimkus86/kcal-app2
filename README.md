# Kcal Log - build the APK with GitHub (no Android Studio needed)

1. Create a free GitHub account and a new repository (private is fine).
2. Upload everything from this folder to the repository, including the
   hidden `.github` folder. If the web upload skips `.github`, use
   Add file > Create new file, type `.github/workflows/build-apk.yml`
   as the name and paste in the contents of that file.
3. Open the repository's **Actions** tab. The "Build APK" workflow runs
   automatically after the upload. If it does not, choose "Build APK"
   and press **Run workflow**.
4. After about 5-10 minutes open the finished run, scroll to
   **Artifacts** and download `kcal-log-apk`. Unzip it to get `app-debug.apk`.
5. Send the APK to your phone, open it and allow "install unknown apps"
   when Android asks.

The app stores data inside the installed app, separately from the web
version. To move data over, use Settings > Copy backup in the web
version and Restore from text in the app.

To update the app later, replace `www/index.html` in the repository and
run the workflow again.
