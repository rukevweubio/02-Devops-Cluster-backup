# Multi-stage Dockerfile for NetflixClone-app

# -- Build stage -----------------------------------------------------------
FROM node:20-alpine AS builder
WORKDIR /app

# Allow build-time injection of the Gemini API key (used at build time by Vite)
ARG NODE_ENV=production
ARG GEMINI_API_KEY
ENV NODE_ENV=${NODE_ENV}
ENV GEMINI_API_KEY=${GEMINI_API_KEY}

# Install dependencies (use package-lock for deterministic installs)
COPY package.json package-lock.json ./
# Ensure dev dependencies (like Vite) are installed for the build step
RUN npm ci --silent --include=dev

# Copy source and build
COPY . .
RUN npm run build

# -- Runtime stage (nginx) -----------------------------------------------
FROM nginx:stable-alpine AS runner

# Copy built app to nginx html folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Add nginx configuration for SPA routing
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
