# Stage 1: Install dependencies and build the application
FROM node:14 AS build

WORKDIR /app

# Build arguments for cache directories
ARG CACHE_DIR
ARG BUILD_DIR

# Copy package.json and yarn.lock to the cache directory to leverage Docker cache
COPY package.json yarn.lock ${CACHE_DIR}/

# Set the cache directory as the working directory
WORKDIR ${CACHE_DIR}

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the files to the cache directory
COPY . .

# Build the application
RUN yarn build

# Stage 2: Setup nginx to serve the built application
FROM nginx:alpine

# Copy built files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
