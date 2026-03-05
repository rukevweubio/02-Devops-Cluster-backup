# --- Build Stage ---
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# --- Runtime Stage ---
FROM nginx:alpine-slim

# Copy build artifacts
WORKDIR /usr/share/nginx/html
COPY --from=build /app/dist .

# Copy your custom config (Ensure it has "listen 8080;")
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# 1. Fix permissions for the directories Nginx needs to touch.
# 2. We grant permissions to GID 0 (root group) because that's what OpenShift uses.
RUN chmod -R 775 /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html && \
    chgrp -R 0 /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html

# 3. Wipe the default 'user' directive from the main nginx.conf 
# This stops the "user directive makes sense only if master runs with super-user" warning.
RUN sed -i 's/^user/#user/' /etc/nginx/nginx.conf

# OpenShift runs as a random UID
USER 1001

# Non-privileged port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]