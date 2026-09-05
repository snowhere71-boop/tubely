# Tubely — mobile (Flutter → .apk)

A complete, working Flutter app: search YouTube, play videos through the
official YouTube player, and save a playlist on-device. It talks to the same
backend as the web version (`../backend`), so your API key never touches the
phone.

## About the .apk specifically

I can't compile the `.apk` myself and attach it here — building an Android
app requires the Android SDK and Google's build tooling, and the sandboxed
environment I write code in has no network access to Google's servers to
download them. So what's in this folder is the complete, real app source,
plus a GitHub Actions workflow that builds the actual `.apk` for you
automatically, for free, the moment you push this code to GitHub. No
Android Studio, no local Flutter install required. That's about a 2-minute
task on your end and takes ~3–5 minutes to run. Steps below.

If you'd rather build it on your own computer instead (see "Option B"),
that works too and skips GitHub entirely.

## Option A — build it with GitHub Actions (recommended, nothing to install)

**1. Deploy the backend first.** The app needs a backend it can reach over
the internet (not your computer's localhost, since your phone can't see
that). Follow the "Deploy the backend" section in `../README.md` — Render's
free tier takes about 5 minutes and needs no credit card. Copy the URL it
gives you, e.g. `https://tubely-backend-xxxx.onrender.com`.

**2. Point the app at your backend.** Open `lib/config.dart` in this folder
and replace the URL:

```dart
const String apiBaseUrl = 'https://tubely-backend-xxxx.onrender.com/api';
```

(Keep the `/api` at the end.)

**3. Push this code to GitHub.**
- Create a new repository at github.com (any name, can be private).
- Upload this `mobile` folder's contents to it — either drag-and-drop
  through GitHub's web uploader, or from a terminal:
  ```
  cd mobile
  git init
  git add .
  git commit -m "Tubely mobile app"
  git branch -M main
  git remote add origin https://github.com/<your-username>/<your-repo>.git
  git push -u origin main
  ```

**4. Get the APK.** Pushing to `main` triggers the build automatically. On
GitHub, open your repo → the **Actions** tab → the running workflow →
wait for the green check (a few minutes) → scroll to **Artifacts** →
download **tubely-apk**. It's a `.zip` containing `app-release.apk` — unzip
it to get the actual APK file.

**5. Install it on your phone.** Transfer the `.apk` to your Android phone
(email it to yourself, use a cloud drive, or a USB cable) and open it there.
Since it's not from the Play Store, Android will ask you to allow
"install from this source" the first time — that's expected for any
sideloaded app, not a sign something's wrong.

Didn't work? Open the failed step in the Actions log — it'll show the exact
error. The most likely one is the YouTube player package having moved its
API slightly since this was written; the fix is almost always contained to
`lib/widgets/player_sheet.dart`, and the pub.dev page for
`youtube_player_flutter` shows the current syntax if it needs a tweak.

## Option B — build it locally (if you already have Flutter installed)

```
cd mobile
flutter create --platforms=android .
flutter pub get
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`. Don't
have Flutter installed? Getting it set up locally is a much bigger lift than
Option A — Option A is the faster path for most people.

## What you get either way

- A signed, installable release APK (signed with Flutter's default debug
  key — fine for installing on your own phone, not set up for Play Store
  publishing, which needs its own signing key)
- Search, tap-to-play in a bottom sheet via YouTube's official player
  (ads and controls untouched), and a persistent "My Playlist" tab

## If the app looks cramped on your phone

The grid card sizing (`childAspectRatio` in `lib/widgets/video_grid.dart`)
is tuned for a typical phone screen but wasn't tested on a real device.
If titles look squeezed or cards look too short, nudge that number down
(e.g. `0.68` → `0.6`) and rebuild.
