FROM node:lts-alpine

# make the 'app' folder the current working directory
WORKDIR /app

# copy both 'package.json' and 'package-lock.json' (if available)
COPY package.json yarn.lock ./

# install project dependencies
RUN yarn install --frozen-lockfile

# copy project files and folders to the current working directory (i.e. 'app' folder)
COPY . .
ARG VITE_BASE 
ARG VITE_ROUTER_MODE 
ARG VITE_BASE_API 
ARG VITE_SOCKET_API

# build app for production with minification
RUN yarn build

EXPOSE 8080
CMD [ "yarn", "preview" ]
