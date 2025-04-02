FROM node:14 AS build
WORKDIR /app

# Copy only package files first to take advantage of Docker layer caching
COPY package.json yarn.lock ./

# Use yarn cache directory and mount it as a cache volume
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn,id=yarn_cache \
    yarn install --frozen-lockfile

# Then copy application code
COPY . .

# Use the same cache mount for the build step
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn,id=yarn_cache \
    yarn build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 90
CMD ["nginx", "-g", "daemon off;"]
