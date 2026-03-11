# ---------- Build stage ----------
FROM node:20-bookworm-slim AS builder
WORKDIR /app

# 编译 native 模块需要的工具
RUN apt-get update && apt-get install -y \
  python3 make g++ \
  && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build
RUN npm prune --omit=dev

# ---------- Runtime stage ----------
FROM node:20-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server ./server

EXPOSE 3001
CMD ["node", "--env-file=.env", "server/index.js"]
