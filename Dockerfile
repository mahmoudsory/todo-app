# syntax=docker/dockerfile:1.3

FROM node:14 AS build

WORKDIR /app

# 1. Copy only the files needed for installing dependencies
COPY package.json yarn.lock ./

# 2. Install dependencies (this will be cached if nothing changes in step 1)
RUN yarn install --frozen-lockfile

# 3. Copy the rest of the app separately
COPY public ./public
COPY src ./src
COPY vue.config.js ./

# 4. Build the app
RUN yarn build

# 5. Serve with nginx
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
