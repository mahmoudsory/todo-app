# Stage 1: Install dependencies using Yarn 2+
FROM node:14-alpine AS dependencies

WORKDIR /app

# Copy only package.json, yarn.lock, and .yarnrc.yml for caching
COPY package.json yarn.lock .yarnrc.yml ./

# Install Yarn 2+ (Berry)
RUN yarn set version berry

# Install dependencies with immutable mode (frozen lockfile equivalent)
RUN yarn install --immutable

# Stage 2: Build the application
FROM node:14-alpine AS build

WORKDIR /app

# Copy Yarn cache and PnP file from the dependencies stage
COPY --from=dependencies /app/.yarn ./.yarn
COPY --from=dependencies /app/.pnp.cjs ./.pnp.cjs

# Copy the rest of the application code
COPY . .

# Build the application
RUN yarn build

# Stage 3: Serve the application with Nginx
FROM nginx:alpine

# Copy the built application from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy the Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
