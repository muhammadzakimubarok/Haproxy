#!/bin/bash

ROOTPASS="bogor123"

NODE1="172.16.15.200"
NODE2="172.16.15.201"
LB="172.16.15.199"

echo "======================================"
echo "INSTALL SSHPASS"
echo "======================================"

apt update
apt install -y sshpass haproxy

####################################
# NODE 1
####################################

echo "Konfigurasi Node1..."

sshpass -p "$ROOTPASS" ssh -o StrictHostKeyChecking=no root@$NODE1 <<'EOF'

apt update

apt install -y apache2 php-fpm php php-cli libapache2-mod-fcgid

a2enmod proxy_fcgi setenvif
a2enconf php8.2-fpm
rm /var/www/html/index.html

cat > /var/www/html/index.php <<HTML
<h1>SERVER NODE 1</h1>
<p>IP : 172.16.15.200</p>
HTML

systemctl restart apache2
systemctl restart php8.2-fpm

EOF

####################################
# NODE 2
####################################

echo "Konfigurasi Node2..."

sshpass -p "$ROOTPASS" ssh -o StrictHostKeyChecking=no root@$NODE2 <<'EOF'

apt update

apt install -y apache2 php-fpm php php-cli libapache2-mod-fcgid

a2enmod proxy_fcgi setenvif
a2enconf php8.2-fpm
rm /var/www/html/index.html

cat > /var/www/html/index.php <<HTML
<h1>SERVER NODE 2</h1>
<p>IP : 172.16.15.201</p>
HTML

systemctl restart apache2
systemctl restart php8.2-fpm

EOF


####################################
# HAPROXY
####################################

echo "Konfigurasi HAProxy..."

cat > /etc/haproxy/haproxy.cfg <<EOF

global
    log /dev/log local0
    log /dev/log local1 notice
    daemon
    maxconn 2000

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend web_front
    bind *:80
    default_backend web_backend

backend web_backend
    balance roundrobin

    option httpchk GET /

    server node1 172.16.15.200:80 check
    server node2 172.16.15.201:80 check

listen stats
    bind *:8080
    stats enable
    stats uri /stats
    stats refresh 5s
    stats auth admin:admin123

EOF

systemctl enable haproxy
systemctl restart haproxy

echo "======================================"
echo "SELESAI"
echo "======================================"

echo "Akses Website:"
echo "http://$LB"

echo ""
echo "Akses Statistik:"
echo "http://$LB:8080/stats"
echo "user : admin"
echo "pass : admin123"
