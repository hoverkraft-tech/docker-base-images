FROM node:25-alpine

WORKDIR /workspace

# Create user and group
RUN addgroup -S tester \
    && adduser -S -G tester tester

# Copy package files and install dependencies
COPY package.json package-lock.json* ./
RUN npm ci

COPY entrypoint.sh /usr/local/bin/testcontainers-node-entrypoint
RUN chmod +x /usr/local/bin/testcontainers-node-entrypoint

WORKDIR /workspace/image

# Drop privileges
USER tester

ENTRYPOINT ["/usr/local/bin/testcontainers-node-entrypoint"]

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["node", "--version"]
