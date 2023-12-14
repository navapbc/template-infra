FROM python:3-alpine as release

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
