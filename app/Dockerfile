# Simple hello, world image mostly copied
# from https://github.com/crccheck/docker-hello-world
FROM busybox:latest AS release
ENV PORT=8000

ADD index.html /www/index.html

EXPOSE $PORT

HEALTHCHECK CMD nc -z localhost $PORT

# Create a basic webserver and run it until the container is stopped
CMD echo "httpd started" && trap "exit 0;" TERM INT; httpd -v -p $PORT -h /www -f & wait
