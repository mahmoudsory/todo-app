# syntax=docker/dockerfile:1.3

FROM node:14 AS build

WORKDIR /app

# Set an env var to disable linting
ENV DISABLE_ESLINT=true

# Copy only what's needed to install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy source files and other config
COPY public ./public
COPY src ./src
COPY vue.config.js ./

# Build the app (with ESLint disabled via vue.config.js)
RUN yarn build

# Serve using nginx
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
