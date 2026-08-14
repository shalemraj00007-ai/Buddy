# ============================================================
# Buddy — single container: builds the web UI and runs the API.
# The server serves both the app and the API on one port.
# ============================================================

# Stage 1 — install deps + build the web frontend.
# node:20-bookworm (full, not slim) includes the build tools that
# better-sqlite3 needs to compile its native binding.
FROM node:20-bookworm AS build

WORKDIR /app

# Copy manifests first for better layer caching.
COPY package.json ./
COPY server/package.json server/package.json
COPY web/package.json web/package.json
COPY server/tsconfig.json server/tsconfig.json
COPY web/tsconfig.json web/tsconfig.json
COPY web/vite.config.ts web/vite.config.ts
COPY web/index.html web/index.html

RUN cd server && npm install
RUN cd web && npm install

# Copy source and build the web UI.
COPY server server
COPY web web
RUN cd web && npm run build

# ============================================================
# Stage 2 — slim runtime.
FROM node:20-bookworm-slim

ENV NODE_ENV=production
ENV PORT=4000
ENV DATA_DIR=/data

WORKDIR /app

# Copy the server (incl. its node_modules with tsx) and the built web app.
COPY --from=build /app/server /app/server
COPY --from=build /app/web/dist /app/web/dist

WORKDIR /app/server

# SQLite data (db + uploads) lives here. Mount a persistent volume.
VOLUME /data
ENV DATA_DIR=/data

EXPOSE 4000

# Run the server via tsx (handles the app's ESM imports).
CMD ["node", "node_modules/tsx/dist/cli.mjs", "src/index.ts"]
