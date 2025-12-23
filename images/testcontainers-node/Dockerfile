FROM node:25-alpine

WORKDIR /workspace

# Create user and group
RUN addgroup -S tester \
    && adduser -S -G tester tester

# Copy package files and install dependencies
COPY package.json package-lock.json* ./
RUN npm ci

# Drop privileges
USER tester

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 CMD ["node", "--version"]
