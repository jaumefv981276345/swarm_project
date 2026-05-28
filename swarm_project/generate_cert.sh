#!/bin/bash

mkdir -p certs

openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout certs/servidor.key \
-out certs/servidor.crt \
-subj "/C=ES/ST=Baleares/L=Palma/O=SMX/CN=swarm.local"

echo "Certificado generado"