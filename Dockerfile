# Stage 1: Build App
FROM node:14 AS build

WORKDIR /app

# Accept Yarn cache folder path from build arg
ARG YARN_CACHE_FOLDER=/yarn-cache

# Set Yarn to use the custom cache folder
RUN yarn config set cache-folder $YARN_CACHE_FOLDER

# Copy only dependency files first to optimize Docker cache
COPY package.json yarn.lock ./

# Install dependencies with cache mount
RUN --mount=type=cache,target=$YARN_CACHE_FOLDER \
    yarn install --frozen-lockfile

# Then copy the full source (will only bust cache from here on if changed)
COPY . .

# Build the app
RUN yarn build

# Stage 2: Serve App
FROM nginx:alpine

# Copy the built frontend files to nginx web root
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
