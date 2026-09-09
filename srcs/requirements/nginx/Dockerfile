FROM debian:13

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    gettext \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf.template
COPY tools/nginx-init.sh /usr/local/bin/nginx-init.sh

RUN chmod +x /usr/local/bin/nginx-init.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx-init.sh"]
