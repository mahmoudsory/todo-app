FROM node:14 AS build

WORKDIR /app

COPY package.json yarn.lock ./

RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn install --frozen-lockfile

COPY . .

RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn build

FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
