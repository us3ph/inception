FROM debian:trixie

RUN apt-get update -y && \
    apt-get install -y mariadb-server mariadb-client

RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld && \
    chmod 755 /run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/mariadb-setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mariadb-setup.sh

EXPOSE 3306

ENTRYPOINT ["mariadb-setup.sh"]
