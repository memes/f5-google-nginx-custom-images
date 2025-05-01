#!/bin/sh
#
# This script will replace the contents of /etc/nginx.conf and /etc/nginx-agent/nginx-agent.conf as an example of how to
# perform full configuration of a golden NGINX+ image.
# shellcheck disable=SC2154

info()
{
    echo "$0: INFO: $*" >&2
}

error()
{
    echo "$0: ERROR: $*" >&2
    exit 1
}

# This is essentially the same as pre-installed default.conf, but with /api/ enabled.
cat <<NGINX_CONF > /etc/nginx/conf.d/default.conf || error "Failed to replace /etc/nginx.conf: $?"
server {
  listen       80 default_server;
  server_name  localhost;

  location / {
    root   /usr/share/nginx/html;
    index  index.html index.htm;
  }

  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
    root   /usr/share/nginx/html;
  }
  location /api/ {
    api write=on;
    allow 127.0.0.1;
    deny all;
  }
}
NGINX_CONF

nginx -t || error "Failed to verify updated NGINX+ configuration"

cat <<AGENT_CONF > /etc/nginx-agent/nginx-agent.conf || error "Failed to replace /etc/nginx-agent/nginx-agent.conf: $?"
server:
  token: "${nginx_one_key}"
  host: agent.connect.nginx.com
  grpcPort: 443
  backoff:
    initial_interval: 100ms
    randomization_factor: 0.10
    multiplier: 1.5
    max_interval: 1m
    max_elapsed_time: 0
tls:
  enable: true
  skip_verify: false
log:
  level: info
  path: /var/log/nginx-agent/
nginx:
  exclude_logs: ""
  socket: "unix:/var/run/nginx-agent/nginx.sock"
dataplane:
  status:
    poll_interval: 30s
    report_interval: 24h
metrics:
  bulk_size: 20
  report_interval: 1m
  collection_interval: 15s
  mode: aggregated
  backoff:
    initial_interval: 100ms
    randomization_factor: 0.10
    multiplier: 1.5
    max_interval: 1m
    max_elapsed_time: 0
config_dirs: "/etc/nginx:/usr/local/etc/nginx:/usr/share/nginx/modules:/etc/nms"
queue_size: 100
extensions:
  - nginx-app-protect
nginx_app_protect:
  report_interval: 15s
  precompiled_publication: true
AGENT_CONF
