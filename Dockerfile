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
FROM node:lts-alpine

WORKDIR /app

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only the built app from the build stage
COPY --from=build /app/dist /app/dist
COPY --from=build /app/package.json /app/yarn.lock ./

# Install dependencies including Vite which is needed for the preview command
# We need to install ALL dependencies since vite is used by the preview command
RUN yarn install --frozen-lockfile

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080 || exit 1

# Expose the correct port
EXPOSE 8080

# Start the app with specific host to make it accessible
CMD [ "yarn", "preview", "--host", "0.0.0.0", "--port", "8080" ]
