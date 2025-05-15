# Build stage
FROM node:lts-alpine AS build

# make the 'app' folder the current working directory
WORKDIR /app

# copy both 'package.json' and 'package-lock.json' (if available)
COPY package.json yarn.lock ./

# install project dependencies
RUN yarn install --frozen-lockfile

# copy project files and folders to the current working directory
COPY . .

# Build arguments for environment variables
ARG VITE_BASE 
ARG VITE_ROUTER_MODE 
ARG VITE_BASE_API 
ARG VITE_SOCKET_API

# build app for production with minification
RUN yarn build

# Production stage
FROM nginx:alpine

# Build arguments for environment variables
ARG VITE_BASE 
ARG VITE_ROUTER_MODE 
ARG VITE_BASE_API 
ARG VITE_SOCKET_API

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built files from the build stage to nginx's serve directory
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Nginx starts automatically
CMD ["nginx", "-g", "daemon off;"]
