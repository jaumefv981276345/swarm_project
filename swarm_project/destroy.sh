#!/bin/bash

docker rm -f node-manager node-worker1 node-worker2 2>/dev/null
docker network rm swarm-net 2>/dev/null

echo "Entorno eliminado"