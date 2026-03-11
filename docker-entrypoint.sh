#!/bin/sh
sed -i "s|https://mainnet.infura.io/alethio|/jsonrpc|g" /usr/share/nginx/html/js/app.*.js
exec /docker-entrypoint.sh "$@"
