FROM nginx:1.30.4-alpine
COPY site/ /usr/share/nginx/html/
