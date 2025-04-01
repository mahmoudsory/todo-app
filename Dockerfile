# syntax=docker/dockerfile:1.3

### Step 1: Build Stage
FROM node:14 AS build

WORKDIR /app

# Cache dependency installation
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy the rest of the source code
COPY . .

# Build the application
RUN yarn build

### Step 2: Production Stage
FROM nginx:alpine

# Copy built files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Use custom nginx config if needed
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
