FROM node:20-alpine

WORKDIR /workspace

# Install docker cli (needed for testcontainers)
RUN apk add --no-cache docker-cli \
    && addgroup -S tester \
    && adduser -S -G tester tester

# Copy package files and install dependencies
COPY images/testcontainers-node/package.json images/testcontainers-node/package-lock.json* ./
RUN npm ci --omit=dev || npm install --omit=dev

# Drop privileges
USER tester

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["node", "--version"]
