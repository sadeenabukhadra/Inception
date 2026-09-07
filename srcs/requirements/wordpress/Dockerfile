FROM debian:15.12

RUN apt-get update && apt-get install -y \
    php8.4 \
    php8.4-fpm \
    php8.4-mysql \
    php8.4-curl \
    php8.4-gd \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-zip \
    php8.4-imagick \
    curl \
    mariadb-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html /run/php

RUN curl -fsSL https://wordpress.org/latest.tar.gz \
    -o /tmp/wordpress.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /tmp \
    && cp -a /tmp/wordpress/. /var/www/html/ \
    && rm -rf /tmp/wordpress /tmp/wordpress.tar.gz

COPY conf/www.conf /etc/php/8.4/fpm/pool.d/www.conf
COPY tools/wordpress-init.sh /usr/local/bin/wordpress-init.sh

RUN chmod +x /usr/local/bin/wordpress-init.sh \
    && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress-init.sh"]