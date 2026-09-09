FROM debian:13

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/mysql/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb-init.sh /usr/local/bin/mariadb-init.sh

RUN chmod +x /usr/local/bin/mariadb-init.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-init.sh"]
