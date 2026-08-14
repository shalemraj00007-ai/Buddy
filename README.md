# Buddy — Your Personal AI Assistant

A real, full-stack personal AI assistant. Buddy chats naturally, **remembers
useful things about you across conversations**, manages **tasks**, **projects**
and **reminders**, understands **images and documents**, supports **voice**, and
gives you a personalized **Daily** dashboard — while keeping your data on your
own server.

> Built as a real application, not a mockup. The AI runs behind a provider
> abstraction so the model can be swapped without rewriting the app.

---

## Architecture

```
buddy/
├── server/   Node + Express + TypeScript + SQLite   (the "brain" + data)
│   └── src/
│       ├── ai/           AI provider abstraction (Ollama, OpenAI-compatible, none)
│       ├── memory/       long-term memory + relevance retrieval + extraction
│       ├── tools/        modular tools (tasks, reminders, projects, memory,
│       │                 calculator, time, web search)
│       ├── services/     chat orchestration, conversations, tasks, projects,
│       │                 reminders, files/documents, daily, search, scheduler
│       ├── auth/         JWT auth, user isolation, bcrypt
│       ├── routes/       REST API + SSE streaming chat
│       └── db/           SQLite schema (users, conversations, messages,
│                         memories, attachments, projects, tasks, reminders)
└── web/      React + Vite + TypeScript   (responsive UI: mobile/tablet/desktop)
    └── src/
        ├── pages/        Chat, Daily, Tasks, Projects, Memories, Reminders, Settings, Login
        ├── components/   Sidebar, Composer, Markdown (code highlight), Layout
        ├── api/          fetch client + SSE streaming
        └── store/        auth context
```

`Frontend → REST/SSE → Service layer → AI orchestration → Memory → Tools → DB`

---

## Features

- **AI chat** — streaming replies, markdown, syntax-highlighted code, copy,
  regenerate, edit your message, stop generation, conversation history with
  search / rename / delete, images & document attachments.
- **Buddy personality** — friendly, calm, honest; adapts style to context and
  acknowledges emotional signals briefly without overdoing it.
- **Long-term memory** — structured memories (category, content, importance,
  timestamps) with relevance retrieval. Buddy decides what's worth remembering
  (preferences, goals, projects, skills) and won't store every message.
  Dedup + memory enable/disable + full controls in the Memories screen.
- **Personal context** — each reply is built from the message + conversation +
  only the relevant memories + open tasks + projects + upcoming reminders.
- **Conversation history** — persisted in SQLite, survives restarts, isolated
  per user.
- **Images & vision** — upload images, preview, ask Buddy about them (vision
  model integration point).
- **Documents** — PDF, DOCX, TXT, Markdown, CSV. Extracted text is fed to the
  model; large files are guarded/chunked rather than sent whole.
- **Voice** — browser speech-to-text (microphone) + text-to-speech (listen).
- **Tasks** — create/edit/complete/delete, priority, due date, filter & sort.
  Buddy can manage them in natural language: *"Add a task to finish the login
  system tomorrow."*
- **Projects** — with tasks, progress, colors, status. Project context is
  understood (e.g. "continue working on the authentication system").
- **Reminders** — one-time and recurring (daily/weekly), enable/disable,
  edited & deleted from chat or the UI. A server scheduler fires them
  (platform notification delivery is a documented integration point).
- **Daily dashboard** — greeting, today's priorities, reminders, goals,
  project progress, and a real personalized suggestion from your data.
- **Web search** — modular, separate from the core AI; gated behind config.
- **Settings** — profile, AI style, language, memory, voice, notifications,
  appearance, and full account deletion (privacy).
- **Security** — JWT auth, per-user data isolation, input validation, secrets
  only in server env vars (never client-side), friendly error messages with no
  stack traces or keys.

---

## Running it (development)

```bash
# 1. Backend
cd server && npm install && cp .env.example .env && npm run dev   # API :4000

# 2. Frontend (separate terminal)
cd web && npm install && npm run dev                              # UI  :5173
```

## Deploying & using on your phone

See **[DEPLOY.md](DEPLOY.md)** for step-by-step instructions. Quick summary:

- **On your own Windows PC (recommended, private):** run `start-buddy.cmd`,
  allow port `4000` in Windows Firewall, find your LAN IP with `ipconfig`, then
  open `http://YOUR-LAN-IP:4000` on your phone (same Wi‑Fi). Install to the
  home screen as a PWA.
- **In the cloud (access anywhere):** deploy `server/` to Render/Railway/Fly.io
  with a persistent disk. The server serves the built web app and API together
  on one port, so a single deployment is enough.

---

## Connecting a real AI model

The server defaults to the `none` provider, which tells the user honestly that
a model isn't configured. To get real AI, edit `server/.env`:

**Option A — local & private (recommended):** install [Ollama](https://ollama.com)
and pull a model, then set:
```
AI_PROVIDER=ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2          # your model
OLLAMA_VISION_MODEL=llava      # optional, for image questions
```

**Option B — OpenAI-compatible** (OpenAI or any compatible endpoint):
```
AI_PROVIDER=openai
OPENAI_API_KEY=sk-...          # stays on the server, never in the client
OPENAI_MODEL=gpt-4o-mini
```

---

## Web search

Search is intentionally a separate, gated module. To enable it:
```
SEARCH_PROVIDER=tavily
SEARCH_API_KEY=tvly-...
```

---

## Integration points (what still needs a real service)

These are wired and functional, but the external part must be configured in
your environment:

| Area | Status | Notes |
|------|--------|-------|
| Chat AI | ✅ | Works with Ollama / OpenAI-compatible / none |
| Vision | ✅ | Uses your provider's vision model |
| Speech-to-text / TTS | ✅ | Browser Web Speech API, no setup |
| Web search | ⚙️ | Needs a search provider + key in `.env` |
| Reminder push delivery | ⚙️ | Server scheduler fires reminders; wire your platform notifier (Web Push / local notifications) into `services/scheduler.ts` |
| Notification delivery | ⚙️ | Same integration point |

Everything else — chat, memory, context, tasks, projects, reminders,
documents, images, daily, auth, security — runs out of the box.

---

## Demo account

A seeded account exists for the live preview: **`demo@buddy.ai` / `demo1234`**
(or create your own via the Sign up screen).

---

## Tech notes

- **SQLite** (better-sqlite3) for real persistence; schema in `db/schema.ts`.
- **SSE** for streaming chat responses through the Vite proxy.
- Markdown via `react-markdown` + `remark-gfm`; code highlighting via
  `highlight.js`.
- TypeScript strict on both server and client; both `tsc --noEmit` clean.
