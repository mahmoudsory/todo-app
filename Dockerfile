# syntax=docker/dockerfile:1.4

FROM node:14 AS build

WORKDIR /app

# Only copy dependency files first for layer caching
COPY package.json yarn.lock ./

# Cache Yarn downloads using BuildKit mount cache
RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn install --frozen-lockfile

# Copy the rest of the files
COPY . .

# Cache build step too (if it uses yarn's cache again)
RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn build

# Final Nginx image
FROM nginx:alpine

# Copy built app
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
