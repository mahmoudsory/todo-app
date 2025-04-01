# Stage 1: Build App
FROM node:14 AS build

WORKDIR /app

# Accept Yarn cache directory from host
ARG YARN_CACHE_FOLDER=/yarn-cache

# Use BuildKit mount to cache yarn files across builds
RUN yarn config set cache-folder $YARN_CACHE_FOLDER

# Copy only dependency files first to leverage layer caching
COPY package.json yarn.lock ./

# Use cache mount for faster installs
RUN --mount=type=cache,target=$YARN_CACHE_FOLDER \
    yarn install --frozen-lockfile

# Now copy the rest of the app
COPY . .

# Build the app
RUN yarn build

# Stage 2: Serve App
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
