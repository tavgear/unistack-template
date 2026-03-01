FROM  node:24-slim AS dependencies

# Stage 1: Install dependencies
WORKDIR /app

COPY ./front/package.json ./front/package-lock.json ./

RUN --mount=type=cache,target=/root/.npm npm ci --no-audit --no-fund

# Stage 2: Build the application
FROM  node:24-slim AS builder

ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

WORKDIR /app

COPY --from=dependencies /app/node_modules ./node_modules

COPY ./front ./

RUN --mount=type=cache,target=/app/.next/cache npm run build

# Stage 3: Runner image
FROM  node:24-slim AS runner

RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy build artifacts
COPY --from=builder --chown=node:node /app/public ./public
COPY --from=builder --chown=node:node /app/.next/standalone ./
COPY --from=builder --chown=node:node /app/.next/static ./.next/static

USER node

# Run standalone Next.js server
CMD ["node", "server.js"]
