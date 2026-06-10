#!/bin/sh

for NODE in node-manager node-worker1 node-worker2
do
    echo "[*] Configurando firewall en $NODE"

    docker exec "$NODE" sh -c '
        apk add --no-cache iptables >/dev/null 2>&1

        iptables -F
        iptables -X

        iptables -P INPUT DROP
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT

        iptables -A INPUT -i lo -j ACCEPT

        iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

        iptables -A INPUT -s 172.16.0.0/12 -j ACCEPT
        iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT

        iptables -A INPUT -p tcp --dport 22 -j ACCEPT
        iptables -A INPUT -p tcp --dport 80 -j ACCEPT
        iptables -A INPUT -p tcp --dport 443 -j ACCEPT

        iptables -A INPUT -m limit --limit 5/min \
            -j LOG --log-prefix "FIREWALL DROP INPUT: "

        echo "[+] Aplicando reglas iptables"
    '

    echo "[✔] Firewall aplicado en $NODE"
done

echo "[✔] Firewall aplicado en todos los nodos"