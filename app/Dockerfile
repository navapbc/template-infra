# Use the Active LTS version of Node.
# See https://nodejs.org/en/about/releases/
FROM node:16-alpine
# Keep container packages up-to-date.
# -U runs both apk update and apk upgrade.
RUN apk -U upgrade
# Copy just the package data to the working directory.
COPY yarn.lock /srv
COPY package.json /srv
WORKDIR /srv
# Install application dependencies.
RUN yarn install --frozen-lockfile
# Copy all the remaining application files (ignoring files in .dockerignore) to the working directory.
COPY . /srv
# Build the application.
RUN yarn build
# Run the application.
CMD yarn start
