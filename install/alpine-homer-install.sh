#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apk add --no-cache curl wget unzip nodejs npm
msg_ok "Installed Dependencies"

msg_info "Installing Homer"
mkdir -p /opt/homer
cd /opt/homer
wget -q https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip
unzip homer.zip &>/dev/null
rm homer.zip
cp assets/config.yml.dist assets/config.yml
msg_ok "Installed Homer"

msg_info "Creating Service"
cat <<EOF >/etc/init.d/homer
#!/sbin/openrc-run

name="homer"
description="Homer dashboard"
command="/usr/bin/node"
command_args="/opt/homer/index.js"
command_background=true
pidfile="/run/\${RC_SVCNAME}.pid"
directory="/opt/homer"

depend() {
    need net
    after firewall
}
EOF
chmod +x /etc/init.d/homer
rc-update add homer default
rc-service homer start
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apk cache clean
msg_ok "Cleaned"
