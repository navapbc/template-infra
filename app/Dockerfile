# Use the Active LTS version of Node.
# See https://nodejs.org/en/about/releases/
FROM node:16
# Keep container packages up-to-date.
RUN apt update \
    && apt upgrade -y
# Copy all the application files to a working directory.
COPY . /srv
WORKDIR /srv
# Install application dependencies and build the applicatian.
# See package.json for yarn commands.
RUN yarn install --frozen-lockfile \
    && yarn build
# Run the application.
CMD yarn start
