FROM mariadb:10.4

RUN set -eux; \
	apt-get update && \
	apt-get install -y gosu && \
	rm -rf /var/lib/apt/lists/* && \
	gosu nobody true

ADD my.cnf /etc/mysql/my.cnf

ADD entrypoint /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]
CMD ["mysqld", "--innodb_data_home_dir=/var/lib/mysql-custom"]
