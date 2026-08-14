# Deploy Buddy to the Cloud & Use It on Your Phone Anywhere

This guide deploys Buddy to the **cloud** so you can open it on your phone
from **anywhere** (home, work, mobile data) at a `https://your-app-url.com`.

Two easy options are covered — **Render** and **Railway**. Both are "connect
your GitHub repo, we run it" services with **persistent storage** so your
memories, tasks and projects survive restarts.

> ⏱️ Expect ~10–15 minutes the first time (the container builds from scratch).
> After that it starts in seconds.

---

## Before you start (both options)

1. **Put Buddy on GitHub.** You need a free [GitHub](https://github.com) account.

   **Easy way (no git installed):** on github.com click **New repository** →
   name it `buddy` → **Create**. Then on the repo page click **uploading an
   existing file** and drag the whole `buddy` folder contents into it
   (keep the folder structure). Click **Commit changes**.

   **Command-line way (if you have Git for Windows):**
   ```bash
   cd buddy
   git init
   git add .
   git commit -m "Buddy"
   # create an empty repo on github.com named "buddy", then:
   git remote add origin https://github.com/YOUR_USERNAME/buddy.git
   git branch -M main
   git push -u origin main
   ```
   The `.gitignore` already keeps your `.env`, `node_modules`, and `data`
   out of the repo — your secrets and private data are never uploaded.

2. Make sure you set a **strong `JWT_SECRET`** in the dashboard (see below).
   This keeps accounts secure.

---

## Option 1 — Render (recommended, has a free tier)

1. Create a free account at [render.com](https://render.com) (GitHub sign-in is
   easiest).
2. Click **New → Blueprint** (or **Web Service**).
3. Connect your GitHub and select the **buddy** repo.
4. Edit the generated blueprint so the env var **`JWT_SECRET`** is filled in
   with a long random string (e.g. open a site like
   [random.org](https://random.org) and paste a 32+ char string). Leave
   `sync: false` values to "set manually" if you prefer — Render will prompt.
5. In the service's **Settings → Disks**, confirm a disk is mounted at **`/data`**
   (the `render.yaml` already requests one — if not, add it).
6. Click **Deploy** and wait for the build (~10 min first time).
7. When it says **Live**, click the URL. You'll get something like
   `https://buddy.onrender.com`. Open it on your phone, create an account,
   and install it to the home screen (Chrome ⋮ → Add to Home Screen).

> **Free-tier note:** Render's free web services **pause after 15 minutes of
> inactivity** and take ~30s to wake up. Your data is safe (it's on the disk),
> but the first request after a pause will be slow. For instant response,
> upgrade to a paid plan or use Railway.

---

## Option 2 — Railway (simplest, small monthly cost ~$5)

1. Create an account at [railway.app](https://railway.app) (GitHub sign-in).
2. Click **New Project → Deploy from GitHub repo** and pick **buddy**.
3. Railway reads the `Dockerfile` automatically and starts deploying.
4. Add a **Volume**: Project → your service → **Volumes** → **New Volume**,
   mount path **`/data`**, size 1 GB. (This is what makes your data persist.)
5. **Settings → Variables** — add:
   - `JWT_SECRET` — a long random string
   - `AI_PROVIDER` — `none` for now (or `openai` to enable AI, see below)
6. Wait for the deploy to finish, then click **Settings → Networking** →
   **Generate Domain** to get a `https://...up.railway.app` URL.
7. Open it on your phone, sign up, and install to the home screen.

---

## Adding a real AI "brain" in the cloud

On a cloud free tier you generally **can't run Ollama** (it's a local model).
Instead, point Buddy at a hosted model:

1. Get an API key from a provider, e.g. [OpenAI](https://platform.openai.com).
2. In your Render/Railway dashboard set:
   ```
   AI_PROVIDER=openai
   OPENAI_API_KEY=sk-...
   OPENAI_MODEL=gpt-4o-mini
   ```
3. Redeploy (or it applies automatically on some platforms).
   Buddy now uses that model for chat, image questions and document summaries.

The key stays on the server — it is **never** sent to the phone/browser.

---

## If you want AI + full privacy + no per-user cost

Run Buddy on your own **Windows PC** instead (see **DEPLOY.md**), which lets
you use a **local Ollama model** for free. The trade-off is that you can only
reach it from home Wi‑Fi. Choose based on whether you need "from anywhere"
(cloud) or "fully private" (your PC).

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Build fails | Check build logs. If `npm install` fails for better-sqlite3, the container needs build tools — the Dockerfile uses `node:20-bookworm` (full image) which includes them. |
| Data disappears after restart | The `/data` disk must be attached. On Render confirm the Disk is mounted at `/data`; on Railway add a Volume at `/data`. |
| "Authentication required" errors | Set a `JWT_SECRET` variable. |
| Slow first load / wakes up late | Render free tier pauses after 15 min. Use a paid plan or Railway for always-on. |
| No AI replies | `AI_PROVIDER` must be `openai` with a valid `OPENAI_API_KEY` (cloud can't run Ollama). |
| Domain not working | On Railway, click **Generate Domain** under Settings → Networking. |

## Security reminders

- Your `.env` is never uploaded (it's git-ignored). Set secrets as **server
  environment variables** instead.
- Every user only sees their own conversations, memories, tasks, projects and
  files — enforced on the backend, not just the UI.
- Use a strong `JWT_SECRET`.
