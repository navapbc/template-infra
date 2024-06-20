# Pin to Alpine 3.19 since aws-cli was removed in Alpine 3.20
# see https://github.com/alpinelinux/docker-alpine/issues/396
# https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.20.0#aws-cli
FROM python:3-alpine3.19 as release

RUN adduser --system --disabled-password --no-create-home app

WORKDIR /app

RUN apk --no-cache add \
  aws-cli~=2 \
  postgresql14-client~=14

COPY requirements.txt ./

RUN pip3 install --no-cache-dir -r requirements.txt

COPY db-migrate /usr/bin/
COPY migrations.sql /app/
COPY *.py /app/

# Set the host to 0.0.0.0 to make the server available external
# to the Docker container that it's running in.
ENV HOST=0.0.0.0

# Run as non-root user
USER app

# Create a basic webserver and run it until the container is stopped
CMD ["python", "-m", "app"]
