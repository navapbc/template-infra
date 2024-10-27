# Use the official Playwright image as a base
FROM mcr.microsoft.com/playwright:v1.48.1-noble

# Install make and any other necessary dependencies
RUN apt-get update && apt-get install -y make

# Set the working directory to the root of the project inside the Docker container
WORKDIR /

# Copy the required files and directories from the root of the project into the Docker container
COPY Makefile /Makefile
COPY e2e /e2e

# Install the dependencies inside the /e2e directory
WORKDIR /e2e
RUN npm ci

# Install Playwright browsers and other necessary system dependencies
RUN npx playwright install --with-deps

# Change the working directory back to the root to run the Makefile
WORKDIR /

# Default command when running the container
CMD ["make", "e2e-test"]
