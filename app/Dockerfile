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

FROM busybox:uclibc AS release

ARG RUN_USER=nobody
USER ${RUN_USER}

COPY index.html /www/index.html
COPY health /www/health
COPY start-server.sh /bin/start-server.sh

# Create a basic webserver and run it until the container is stopped
CMD ["start-server.sh"]
