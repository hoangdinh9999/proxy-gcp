#!/usr/bin/env bash
set -euo pipefail

echo "🛠️ Installing dependencies..."
apt update -y
apt install -y dante-server squid net-tools

echo "🔧 Configuring danted (SOCKS5)..."
cat <<EOF >/etc/danted.conf
logoutput: syslog
internal: 0.0.0.0 port=${MANUAL_PORT:-1080}
external: $(hostname -I | awk '{print $1}')
method: username none
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    log: connect disconnect error
    method: username
    username: "${MANUAL_USERNAME:-proxy}"
}
EOF

echo "SOCKS5 username ${MANUAL_USERNAME:-proxy}" > /etc/socksauth
echo "${MANUAL_USERNAME:-proxy}:${MANUAL_PASSWORD:-proxy}" >> /etc/passwd_proxy
useradd -M -s /sbin/nologin "${MANUAL_USERNAME:-proxy}" || true
echo "${MANUAL_USERNAME:-proxy}:${MANUAL_PASSWORD:-proxy}" | chpasswd

systemctl restart danted
systemctl enable danted

echo "🌐 Configuring squid (HTTP proxy)..."
cat <<EOF >/etc/squid/squid.conf
http_port ${MANUAL_HTTP_PORT:-3128}
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all
EOF

touch /etc/squid/passwd
htpasswd -b -c /etc/squid/passwd "${MANUAL_HTTP_USERNAME:-proxy}" "${MANUAL_HTTP_PASSWORD:-proxy}"

systemctl restart squid
systemctl enable squid

echo "✅ Proxy setup completed."
