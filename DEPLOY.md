# Deploying Buddy & Using It on Your Phone

For a **personal, private** assistant, the best setup is running Buddy on your
own **Windows computer** and opening it from your phone over your home Wi‑Fi.
Free, private, no account needed, and your data never leaves your machine.

You only need to do the **first-time setup** once. After that, one command
starts Buddy whenever you want to use it.

---

## Option A — Host on your own Windows PC (recommended, private)

### Step 1 — Get the code onto your computer

You need [Node.js](https://nodejs.org) (the LTS version, v20 or newer) installed
on your PC. Download and install it from nodejs.org.

Copy the `buddy` folder from here to your computer, e.g. `C:\buddy`.

### Step 2 — First-time setup (one time)

Double‑click **`start-buddy.cmd`** in the `buddy` folder.

This will:
- install the server and web dependencies,
- build the web app,
- start Buddy on **http://localhost:4000**.

Wait for the message: `[Buddy] Starting Buddy on http://localhost:4000`.

> On later runs you can use the faster **`run-buddy.cmd`** (it assumes deps are
> installed and the web app is already built).

### Step 3 — Find your computer's IP address (for the phone)

1. Open a Command Prompt (`Win+R`, type `cmd`, Enter).
2. Run: `ipconfig`
3. Look for your active connection (Wi‑Fi). Find **IPv4 Address**, e.g.
   `192.168.1.5`. That's the address your phone will use.

### Step 4 — Allow the firewall (one time)

Windows will ask if you want to allow Node.js through the firewall — click
**Allow**. If it didn't ask:

1. Search Windows for **Windows Defender Firewall** → **Advanced settings**.
2. **Inbound Rules** → **New Rule** → **Port**.
3. Protocol **TCP**, specific local ports: **4000**.
4. **Allow the connection** → all profiles → name it `Buddy` → **Finish**.

### Step 5 — Open Buddy on your phone

1. Make sure your phone is on the **same Wi‑Fi** as your computer.
2. On your phone's browser open:
   `http://YOUR-LAN-IP:4000`
   (replace `YOUR-LAN-IP` with the address from Step 3, e.g.
   `http://192.168.1.5:4000`).
3. Create an account (or sign in) and start using Buddy.

### Step 6 — Install it like an app (optional but nice)

**Android (Chrome):** open the URL → tap the ⋮ menu → **Add to Home screen** →
**Install**. Buddy now appears on your home screen as a full‑screen app with the
Buddy icon.

**iPhone/iPad (Safari):** open the URL → tap the **Share** button → **Add to
Home Screen** → **Add**.

> You must reach Buddy over `http://LAN-IP:4000` (not `localhost`) for the
> phone to connect. Keep your computer on and Buddy running when you use it.

---

## Adding a real AI "brain" (optional)

Out of the box Buddy manages tasks, projects, reminders, memory and the daily
dashboard without any AI. To give it real conversations, install a local model:

1. Install [Ollama](https://ollama.com) on your PC.
2. Open a terminal and run: `ollama pull llama3.2`
3. In `buddy\server\.env`, set:
   ```
   AI_PROVIDER=ollama
   OLLAMA_BASE_URL=http://localhost:11434
   OLLAMA_MODEL=llama3.2
   ```
4. Restart Buddy (stop it, run `run-buddy.cmd` again).

Buddy will then use your local, private model for chat, image questions and
document summaries.

---

## Option B — Deploy to the cloud (access from anywhere)

If you want to reach Buddy from any network (not just home Wi‑Fi), deploy the
`buddy/server` folder to a Node host. All recommended hosts support Node + a
persistent disk for the SQLite file.

1. Push the `buddy` repo to GitHub/GitLab.
2. On **Render** (render.com, free tier) choose **New → Web Service**, connect
   your repo, set:
   - Root directory: `server`
   - Build command: `npm install`
   - Start command: `npm run start`
   - Add a **Disk** so `./data` persists.
3. Set environment variables: `JWT_SECRET` (a long random string),
   `AI_PROVIDER` (and provider keys if you want real AI).
4. After it deploys, you get a `https://your-app.onrender.com` URL — open it on
   your phone from anywhere and install it to the home screen.

> Your data lives in the SQLite file on that server. The same API + frontend
> are served from one URL automatically.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Phone can't open the URL | Same Wi‑Fi? Firewall allows port 4000? Correct IP? Try `ping YOUR-LAN-IP` from a PC. |
| "Can't connect" on phone but works on PC | Windows Firewall rule for port 4000 (Step 4). Some routers block cross‑device; check router AP isolation is off. |
| Port 4000 already in use | Edit `PORT` in `server\.env` to another value (e.g. `4001`) and use that port. |
| No AI replies | Set `AI_PROVIDER` in `server\.env` and confirm Ollama is running. |
| Forgot demo data | Buddy keeps your data in `buddy\server\data`. Back it up if you move computers. |
| Slow first load | First build can take a minute; later `run-buddy.cmd` starts fast. |

---

## Ports summary

- `4000` — Buddy (web + API together)
- `11434` — Ollama (only if you enabled it)
