# FROM... instruction that defines the base image for all subsequent instructions in that build stage.

#start with debian Bullseye (stable linux version)
FROM debian:bullseye

#update package list and install MariaDB
RUN apt-get update -y && \
    apt-get update -y && \
    apt-get install -y mariadb-server mariadb-client

#copy our configuration file into the container
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

#copy out setup script
COPY tools/mariadb-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-setup.sh

#opens port 3306 so other containers can connect (standard database port)
EXPOSE 3306

#The first thing to run when container starts
#when container starts, run the setup script
ENTRYPOINT ["mariadb-setup.sh"]

#after setup keep MariaDB running
CMD ["mysqld"]