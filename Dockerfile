FROM nginx:1.31.6-alpine
RUN apk update && apk upgrade --no-cache
COPY site/ /usr/share/nginx/html/
