#!/bin/bash

docker exec node-manager docker swarm leave --force 2>/dev/null || true
docker rm -f node-manager node-worker1 node-worker2 2>/dev/null || true
docker network rm swarm-net 2>/dev/null || true

echo "Entorno eliminado"