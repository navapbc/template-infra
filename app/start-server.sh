#!/bin/sh
echo "httpd started on port $PORT" && trap "exit 0;" TERM INT; httpd -v -p $PORT -h /www -f & wait
