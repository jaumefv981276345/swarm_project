#!/bin/bash
set -e

echo "[+] Limpieza previa"
docker rm -f node-manager node-worker1 node-worker2 2>/dev/null || true
docker network rm swarm-net 2>/dev/null || true

echo "[+] Creando red base"
docker network create swarm-net

echo "[+] Creando nodos DinD"
docker run -d --privileged --name node-manager --hostname node-manager --network swarm-net docker:dind
docker run -d --privileged --name node-worker1 --hostname node-worker1 --network swarm-net docker:dind
docker run -d --privileged --name node-worker2 --hostname node-worker2 --network swarm-net docker:dind

echo "[+] Esperando Docker"
sleep 20

echo "[+] Obteniendo IP manager"
MANAGER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' node-manager)

echo "[+] Swarm init"
docker exec node-manager docker swarm init --advertise-addr $MANAGER_IP

TOKEN=$(docker exec node-manager docker swarm join-token -q worker)

echo "[+] Workers join"
docker exec node-worker1 docker swarm join --token $TOKEN $MANAGER_IP:2377
docker exec node-worker2 docker swarm join --token $TOKEN $MANAGER_IP:2377

echo "[+] Esperando nodos"
sleep 5

echo "[+] Overlay network"
docker exec node-manager docker network create -d overlay xarxa_web || true

echo "[+] Build nginx"
docker build -t nginx_https ./nginx

echo "[+] Distribuir imagen"
docker save nginx_https -o nginx.tar
docker cp nginx.tar node-worker1:/nginx.tar
docker cp nginx.tar node-worker2:/nginx.tar
docker exec node-worker1 docker load -i /nginx.tar
docker exec node-worker2 docker load -i /nginx.tar

echo "[+] Copiar certificados"
docker cp certs/. node-manager:/certs/
docker cp certs/. node-worker1:/certs/
docker cp certs/. node-worker2:/certs/

echo "[+] Deploy web"
docker exec node-manager docker service create \
  --name web_nginx \
  --replicas 2 \
  --network xarxa_web \
  --publish 80:80 \
  --publish 443:443 \
  --constraint 'node.role == worker' \
  --mount type=bind,src=/certs,dst=/etc/nginx/certs \
  nginx_https

echo "[+] Deploy client"
docker exec node-manager docker service create \
  --name client_test \
  --replicas 1 \
  --network xarxa_web \
  alpine sleep 10000

echo "[✔] OK"