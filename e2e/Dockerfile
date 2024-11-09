# Use the official Playwright image as a base
FROM mcr.microsoft.com/playwright:v1.48.1-noble

# Install make and any other necessary dependencies
RUN apt-get update && apt-get install -y make

# Set the working directory to the root of the project inside the Docker container
WORKDIR /

# Setup npm install layer that can be cached
COPY Makefile /Makefile
COPY e2e/package.json e2e/package-lock.json /e2e/

# install deps
RUN make e2e-setup-ci

# Copy entire e2e folder over
COPY e2e /e2e

CMD ["make", "e2e-test-native"]
