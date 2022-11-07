# Simple hello, world image mostly copied
# from https://github.com/crccheck/docker-hello-world
#
# Testing
# -------
# After running `make release-build` (see [Releases](../docs/releases.md)),
# you can verify the image works by running
#
#   docker run -p 80:8000 template-infra-app
#
# then visit localhost in a browser (or can use curl from a terminal)

FROM busybox:latest AS release
ENV PORT=8000

ADD index.html /www/index.html
ADD health /www/health

EXPOSE $PORT

HEALTHCHECK CMD nc -z localhost $PORT

# Create a basic webserver and run it until the container is stopped
CMD echo "httpd started" && trap "exit 0;" TERM INT; httpd -v -p $PORT -h /www -f & wait
