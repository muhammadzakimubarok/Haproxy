#!/bin/bash

DOMAIN="zakismkn4.local"
DNS_IP="172.16.15.199"
LB_IP="172.16.15.199"

echo "Install BIND9..."

apt update
apt install -y bind9 bind9-utils bind9-dnsutils

echo "Konfigurasi named.conf.local..."

cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type master;
    file "/etc/bind/db.$DOMAIN";
};

zone "15.16.172.in-addr.arpa" {
    type master;
    file "/etc/bind/db.172.16.15";
};
EOF

echo "Membuat Forward Zone..."

cat > /etc/bind/db.$DOMAIN <<EOF
\$TTL 604800
@ IN SOA ns.$DOMAIN. root.$DOMAIN. (
        2
        604800
        86400
        2419200
        604800 )

@       IN NS      ns.$DOMAIN.

ns      IN A       $DNS_IP

@       IN A       $LB_IP
www     IN A       $LB_IP

loadbalancer IN A  $LB_IP

node1   IN A       172.16.15.200
node2   IN A       172.16.15.201

dns     IN A       $DNS_IP
EOF

echo "Membuat Reverse Zone..."

cat > /etc/bind/db.172.16.15 <<EOF
\$TTL 604800
@ IN SOA ns.$DOMAIN. root.$DOMAIN. (
        2
        604800
        86400
        2419200
        604800 )

@       IN NS      ns.$DOMAIN.

9       IN PTR     loadbalancer.$DOMAIN.
10      IN PTR     node1.$DOMAIN.
11      IN PTR     node2.$DOMAIN.
15      IN PTR     dns.$DOMAIN.
EOF

echo "Validasi Konfigurasi..."

named-checkconf

named-checkzone $DOMAIN /etc/bind/db.$DOMAIN

named-checkzone 15.16.172.in-addr.arpa /etc/bind/db.172.16.15

systemctl restart named
systemctl enable named

echo ""
echo "==================================="
echo "DNS SERVER BERHASIL DIKONFIGURASI"
echo "==================================="
echo "Domain : $DOMAIN"
echo "DNS    : $DNS_IP"
echo "LB     : $LB_IP"