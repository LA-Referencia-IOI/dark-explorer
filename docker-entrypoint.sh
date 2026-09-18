#!/bin/sh
set -eu

# The distribution was built with an absolute SPA base.  Make it relocatable
# at container startup so a declarative edge route can publish it below any
# validated URL prefix without leaking assets or RPC calls to the gateway root.
base_path="${EXPLORER_BASE_PATH:-/explorer}"
web_root="${EXPLORER_WEB_ROOT:-/usr/share/nginx/html}"
nginx_entrypoint="${NGINX_ENTRYPOINT:-/docker-entrypoint.sh}"

if ! printf '%s' "$base_path" | grep -Eq '^/[A-Za-z0-9._~/-]*$'; then
    echo "[ERROR] EXPLORER_BASE_PATH must be an absolute URL path" >&2
    exit 1
fi

# Normalize to no trailing slash internally. An empty value represents the
# public root and produces the expected '/' and '/jsonrpc' browser paths.
base_path="$(printf '%s' "$base_path" | sed 's:/*$::')"
public_prefix="${base_path}/"
rpc_path="${base_path}/jsonrpc"

sed -i \
    -e "s|https://mainnet.infura.io/alethio|${rpc_path}|g" \
    -e "s|c.p=\"/\"|c.p=\"${public_prefix}\"|g" \
    -e "s|mode:\"history\",routes:|base:\"${public_prefix}\",mode:\"history\",routes:|g" \
    -e "s|BASE_URL:\"/\"|BASE_URL:\"${public_prefix}\"|g" \
    "$web_root"/js/app.*.js
sed -i \
    -e "s|href=/|href=${public_prefix}|g" \
    -e "s|src=/|src=${public_prefix}|g" \
    "$web_root/index.html"

exec "$nginx_entrypoint" "$@"
