FROM nginx:1.29-alpine

COPY dist/ /usr/share/nginx/html/
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY docker-entrypoint.sh /usr/local/bin/dark-explorer-entrypoint

RUN chmod +x /usr/local/bin/dark-explorer-entrypoint

ENTRYPOINT ["/usr/local/bin/dark-explorer-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
