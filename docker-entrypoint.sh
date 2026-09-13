#!/bin/sh
# The distribution was built with an absolute SPA base.  Make it relocatable
# at container startup so a declarative edge route can publish it at
# /explorer/ without leaking assets or Vue history links to the gateway root.
sed -i "s|https://mainnet.infura.io/alethio|/jsonrpc|g; s|c.p=\"/\"|c.p=\"/explorer/\"|g; s|mode:\"history\",routes:|base:\"/explorer/\",mode:\"history\",routes:|g; s|BASE_URL:\"/\"|BASE_URL:\"/explorer/\"|g" /usr/share/nginx/html/js/app.*.js
sed -i 's|href=/|href=/explorer/|g; s|src=/|src=/explorer/|g' /usr/share/nginx/html/index.html
exec /docker-entrypoint.sh "$@"
