FROM node:22-alpine

ENV NODE_ENV=production
WORKDIR /app

# 1. Dependencies first: this layer only changes when the lock file changes
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# 2. Then the code: it changes often, but it's cheap to copy
COPY src ./src

# 3. A data folder owned by the non-root user, then switch to that user
RUN mkdir -p /etc/todos && chown node:node /etc/todos
USER node

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/health > /dev/null || exit 1
CMD ["node", "src/index.js"]
