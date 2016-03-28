FROM diegomarangoni/mariadb-galera

COPY my.cnf /etc/mysql/my.cnf
RUN mkdir -p /etc/ssl/mysql
COPY cert.pem /etc/ssl/mysql/
COPY key.pem /etc/ssl/mysql/