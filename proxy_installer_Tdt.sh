#!/usr/bin/env bash
set -euo pipefail

choice=4
config_mode=2

export MANUAL_USERNAME="Tdt12345"
export MANUAL_PASSWORD="Tdt12345"
export MANUAL_HTTP_USERNAME="Tdt12345"
export MANUAL_HTTP_PASSWORD="Tdt12345"
export MANUAL_PORT=1080
export MANUAL_HTTP_PORT=3128

export DEBIAN_FRONTEND=noninteractive

curl -sSL https://raw.githubusercontent.com/hoangdinh9999/proxy-gcp/main/auto_proxy_installer.sh | bash -s -- "$choice" "$config_mode"
