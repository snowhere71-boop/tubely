# Tubely

Search YouTube, play videos through the official YouTube player, and save a
personal playlist — as a web app and as an Android app, sharing one backend
so your API key never sits in either client.

```
tubely/
├── backend/    Express server that proxies YouTube search (both apps use this)
├── frontend/   React web app
└── mobile/     Flutter Android app → see mobile/README.md for the .apk
```

**Building the Android app?** Read `mobile/README.md` — it explains why the
`.apk` isn't attached directly and the exact steps to get one.

## 1. Get a YouTube Data API key

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a new project (or pick an existing one)
3. **APIs & Services → Library** → search "YouTube Data API v3" → Enable
4. **APIs & Services → Credentials → Create Credentials → API key**
5. Copy the key. Optional but recommended: click into the key and restrict
   it to the YouTube Data API v3 under "API restrictions."

This API is free — each project gets 10,000 quota units/day at no cost, no
card required. A search costs 100 units, so budget for roughly **100
searches/day** before you'd hit the daily limit (it resets at midnight
Pacific time); everyday personal use won't come close.

## 2. Run the backend

```
cd backend
npm install
cp .env.example .env
# open .env and paste your API key in
npm run dev
```

Runs on `http://localhost:5000`. Verify it works: `npm test` (in a second
terminal, with the server still running) hits `/api/health` and
`/api/search` and reports pass/fail.

## 3. Run the web app

```
cd frontend
npm install
npm run dev
```

Open the URL it prints (`http://localhost:5173`). The dev server proxies
`/api` requests to your backend automatically.

Or from the repo root, `npm run install:all` then `npm run dev` starts both
at once.

## 4. Build the Android app

See `mobile/README.md`.

## Deploying

**Backend → Render** (free, no card): render.com → New → Web Service →
connect your repo → set root directory to `backend` → build command
`npm install` → start command `npm start` → add the `YOUTUBE_API_KEY`
environment variable. A `render.yaml` is included if you want Render's
one-click Blueprint setup instead. Free web services spin down after 15
minutes of no traffic and take 30–60 seconds to wake back up on the next
request — normal for a free tier, not a bug. (Heroku's free tier no longer
exists — it was discontinued in 2022 — which is why Render is the
recommendation here instead.)

**Web frontend → Vercel or Netlify** (either works, configs for both are
included): point the project at the `frontend` folder. If your backend
is on a different domain than your frontend, set `VITE_API_BASE_URL` in
your hosting provider's environment variables to
`https://your-backend-url/api` before building (see `frontend/.env.example`).

**Android app**: see `mobile/README.md` — it builds through GitHub Actions,
not through Vercel/Netlify/Render.

## Staying within YouTube's rules

This app only uses the YouTube Data API and the official YouTube player
embed — no scraping, no stream extraction, no ad-blocking, and no hiding of
YouTube's branding or controls, which keeps it aligned with the
[YouTube API Services Terms of Service](https://developers.google.com/youtube/terms/api-services-terms-of-service).
Worth a skim if you plan to share this app beyond yourself.
