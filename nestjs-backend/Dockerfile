# syntax=docker/dockerfile:1
# ── NestJS backend — multi-stage build ──────────────────────────────────────
# Stage 1: install deps + build TypeScript + generate Prisma client
FROM node:20-bookworm-slim AS builder
WORKDIR /app

# OpenSSL is required by Prisma's query engine
RUN apt-get update && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY prisma ./prisma
RUN npx prisma generate

COPY . .
RUN npm run build

# ── Stage 2: lean runtime image ─────────────────────────────────────────────
FROM node:20-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production

RUN apt-get update && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/*

# Only production artefacts from the builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY package*.json ./

# Persisted gate photos (mounted as a volume in compose)
RUN mkdir -p uploads/access-logs

EXPOSE 3000

# Apply migrations, then start. `migrate deploy` is safe to run every boot —
# it only applies migrations not yet recorded in the database.
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main"]
