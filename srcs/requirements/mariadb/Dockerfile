FROM debain:15.12

RUN apt-get update &&
    apt-get install -y mriadb-server && \
    rm -rf /var/lib/lists/*

COPY conf/50-server.cnf/etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb-init.sh/usr/local/bin/mariadb-init.sh

RUN chmod +x /usr/local/bin/mariadb-init.sh

ENTRYPOINT ["/usr/local/bin/mariadb-init.sh"]
