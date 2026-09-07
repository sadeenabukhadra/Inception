FROM debian:15.12
RUN apt-get update && apt-get install -y \
    php8.4 \
    php8.4-fpm\
    php8.4-mysql \
    php8.4-curl \
    php8.4-gd \
    php8.4-mbstring \
    php8.4-xml\
    php8.4-zip\
    curl\
    mariadb-client\
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

COPY conf/www.conf /etc/php/8.4/fmp/pool.d/www.conf
COPY tools/wordpress-init.sh/usr/local/bin/wordpress-init.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wordpress-init.sh"]
 

