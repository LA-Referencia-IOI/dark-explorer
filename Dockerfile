FROM nginx:1.29-alpine

COPY dist/ /usr/share/nginx/html/
