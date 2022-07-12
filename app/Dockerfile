# Use the Active LTS version of Node.
# See https://nodejs.org/en/about/releases/
FROM node:16-alpine
# Keep container packages up-to-date.
# -U runs both apk update and apk upgrade.
RUN apk -U upgrade
# Copy all the application files to a working directory.
COPY . /srv
WORKDIR /srv
# Install application dependencies and build the application.
RUN yarn install --frozen-lockfile \
    && yarn build
# Run the application.
CMD yarn start
