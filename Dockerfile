# Stage 1: Install dependencies
FROM node:14 AS dependencies

WORKDIR /app

# Copy only package.json and yarn.lock for caching
COPY package.json yarn.lock ./

# Install dependencies with frozen lockfile
RUN yarn install --frozen-lockfile

# Stage 2: Build the application
FROM node:14 AS build

WORKDIR /app

# Copy dependencies from the previous stage
COPY --from=dependencies /app/node_modules ./node_modules

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
