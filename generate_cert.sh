#!/bin/bash

set -e

echo "[+] Eliminando certificados antiguos"
rm -rf certs
mkdir -p certs

echo "[+] Generando certificado autofirmado para Swarm Nginx"

openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout certs/servidor.key \
-out certs/servidor.crt \
-subj "/C=ES/ST=Baleares/L=Palma/O=SMX/CN=web_nginx" \
-addext "subjectAltName=DNS:web_nginx,DNS:swarm.local,IP:127.0.0.1"

echo "[✔] Certificados generados correctamente"
echo "    - certs/servidor.crt"
echo "    - certs/servidor.key"