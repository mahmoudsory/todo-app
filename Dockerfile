# syntax=docker/dockerfile:1.4

# Stage 1: Dependencies (optimized for caching)
FROM node:14 AS deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN --mount=type=cache,target=/app/.yarn-cache \
    yarn install --frozen-lockfile --production=false && \
    # Create a tar archive for reliable layer caching
    tar -czf /tmp/node_modules.tar.gz node_modules

# Stage 2: Build
FROM node:14 AS builder
WORKDIR /app
# Copy the archived node_modules (better caching)
COPY --from=deps /tmp/node_modules.tar.gz /tmp/
RUN tar -xzf /tmp/node_modules.tar.gz -C ./ && \
    rm /tmp/node_modules.tar.gz
COPY . .
RUN yarn build

# Stage 3: Production
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 90
CMD ["nginx", "-g", "daemon off;"]
