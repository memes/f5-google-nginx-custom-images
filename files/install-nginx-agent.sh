#!/bin/sh
#
# This is a simplified NGINX+ Agent installer for Debian based PAYG instances; it installs the agent from NGINX OSS
# repos to avoid messing about with NGINX+ certificates. It does not attempt to configure the instance - after execution
# /etc/nginx/nginx-agent.conf will be the default from deb package.
#
# For a more robust installer use the instructions published by NGINX at
# https://docs.nginx.com/nginx-agent/installation-upgrade/installation-oss/.

info()
{
    echo "$0: INFO: $*" >&2
}

error()
{
    echo "$0: ERROR: $*" >&2
    exit 1
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo or su before running this script.'

info "Downloading and validating NGINX agent repo keyring"
# Debian 12/Ubuntu Jammy prefer /etc/apt/keyrings as target, make sure it exists for older distributions
# shellcheck disable=SC2174
mkdir -p -m 0755 /etc/apt/keyrings || error "/etc/apt/keyrings is missing"
curl -fsSL --retry 5 --retry-max-time 90 https://nginx.org/keys/nginx_signing.key | \
    gpg --dearmor -o /etc/apt/keyrings/nginx-archive.gpg || \
    error "Failed to download and extract NGINX archive keyring: $?"
for fingerprint in 8540A6F18833A80E9C1653A42FD21310B49F6B46 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 9E9BE90EACBCDE69FE9B204CBCDCD8A38D88A2B3; do
    gpg --dry-run --quiet --no-keyring --import --import-options import-show /etc/apt/keyrings/nginx-archive.gpg | \
        grep -q "${fingerprint}" || error "NGINX archive keyring is missing key with fingerprint ${fingerprint}: $?"
done

info "Installing NGINX agent from repo"
# shellcheck disable=SC2320
echo "deb [signed-by=/etc/apt/keyrings/nginx-archive.gpg] http://packages.nginx.org/nginx-agent/$(lsb_release -si 2>/dev/null | tr '[:upper:]' '[:lower:]')/ $(lsb_release -cs 2>/dev/null) agent" > /etc/apt/sources.list.d/nginx-agent.list || \
    error "Failed to add NGINX agent repo to apt sources: $?"
apt update || error "Failed to update package lists"
apt install --yes --no-install-recommends --no-install-suggests --no-upgrade nginx-agent || error "Failed to install NGINX agent from repo: $?"
nginx-agent -v | grep -Eq '^nginx-agent version v[1-9]+' || \
    error "NGINX agent is not installed"

info "NGINX agent installation complete"
