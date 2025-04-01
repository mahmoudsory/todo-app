# syntax=docker/dockerfile:1.4
FROM node:14 AS builder

WORKDIR /app

COPY package.json yarn.lock ./

RUN --mount=type=cache,target=/usr/local/share/.cache/yarn/v6 \
    --mount=type=cache,target=.yarn/cache \
    --mount=type=bind,from=bind,source=node_modules,target=/app/node_modules,readonly \
    yarn install --frozen-lockfile --prefer-offline

COPY . .

RUN yarn build

FROM nginx:alpine

RUN rm -rf /etc/nginx/conf.d/*

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
