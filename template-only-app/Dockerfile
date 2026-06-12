# Run `make update-docker-digest` to update the image
FROM python:3-alpine@sha256:003970a263347645cd23d4f90929ad16ba7ce7d808ee4674ffcc93cb21cc289f AS release

RUN adduser --system --disabled-password --no-create-home app

WORKDIR /app

RUN apk update && \
  apk --no-cache add \
  aws-cli~=2 \
  postgresql17-client~=17

COPY requirements.txt ./

RUN pip3 install --no-cache-dir -r requirements.txt

COPY db-migrate /usr/bin/
COPY bin/healthcheck-netcat /usr/bin/healthcheck
COPY migrations.sql /app/
COPY *.py /app/
COPY /templates /app/templates

# Set the host to 0.0.0.0 to make the server available external
# to the Docker container that it's running in.
ENV HOST=0.0.0.0

# Run as non-root user
USER app

HEALTHCHECK CMD /usr/bin/healthcheck

# Create a basic webserver and run it until the container is stopped
CMD ["python", "-m", "app"]
