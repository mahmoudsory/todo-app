# Stage 1 is removed — no need to build inside Docker now

FROM nginx:alpine

# Copy pre-built static files from Azure pipeline output
COPY dist /usr/share/nginx/html

# Replace NGINX config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 90

CMD ["nginx", "-g", "daemon off;"]
