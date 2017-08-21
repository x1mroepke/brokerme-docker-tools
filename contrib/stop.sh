#!/bin/sh
/usr/local/bin/docker-compose -f /opt/run-env/prd/docker-compose.yml down
echo y | /usr/bin/docker system prune
