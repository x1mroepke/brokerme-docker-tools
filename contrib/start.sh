#!/bin/sh
echo y | /usr/bin/docker system prune
/usr/local/bin/docker-compose -f /opt/run-env/prd/docker-compose.yml up
