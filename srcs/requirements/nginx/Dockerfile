From debian:15.12
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/ngnix.conf /etc/ngnix/ngnix.conf
COPY tools/ngnix-init.sh /usr/local/bin/ngnix-init.sh


RUN chmod +x /usr/local/bin/nginx-init.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx-init.sh"]
