#start with (stable linux version)
FROM debian:trixie

#update package list and install MariaDB
RUN apt-get update -y && \
    apt-get install -y mariadb-server mariadb-client

#create necessary directories and set permissions
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld && \
    chmod 755 /run/mysqld

#copy our configuration file into the container
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

#copy out setup script
COPY tools/mariadb-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-setup.sh

#opens port 3306 so other containers can connect (standard database port)
EXPOSE 3306

#The first thing to run when container starts
ENTRYPOINT ["mariadb-setup.sh"]
