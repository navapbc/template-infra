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
