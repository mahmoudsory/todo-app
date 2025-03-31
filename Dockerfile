# Stage 1: Build
FROM node:14 AS builder

WORKDIR /app

# Enable Yarn cache
ENV YARN_CACHE_FOLDER=/app/.yarn-cache

# First copy only package files for better layer caching
COPY package.json yarn.lock ./

# Install dependencies with BuildKit cache mount
RUN --mount=type=cache,target=/app/.yarn-cache \
    yarn install --frozen-lockfile --production=false

# Copy all files
COPY . .

# Build the application
RUN yarn build

# Stage 2: Production
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
