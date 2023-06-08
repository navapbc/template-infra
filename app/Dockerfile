# Simple hello, world image mostly copied
# from https://github.com/crccheck/docker-hello-world
#
# Testing
# -------
# After running `make release-build` (see [Releases](../docs/releases.md)),
# you can verify the image works by running
#
#   docker run -e PORT=8000 -p 80:8000 template-infra-app
#
# then visit localhost in a browser (or can use curl from a terminal)

# Based on the image defined here: https://github.com/AerialTechnologies/docker-alpine-aws-cli/blob/master/Dockerfile
# and here: https://github.com/AerialTechnologies/docker-alpine-aws-cli-postgresql/blob/master/Dockerfile

FROM python:alpine as release

RUN adduser --system --disabled-password --no-create-home app

WORKDIR /app

COPY requirements.txt ./

RUN pip3 install --no-cache-dir -r requirements.txt

COPY app.py ./

# Set the host to 0.0.0.0 to make the server available external
# to the Docker container that it's running in.
ENV HOST=0.0.0.0

# Run as non-root user
USER app

# Create a basic webserver and run it until the container is stopped
CMD ["python", "-m", "app"]
