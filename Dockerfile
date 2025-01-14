FROM ubuntu
RUN apt-get update  \
	&& apt-get upgrade -y  \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y debconf-utils  \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 mariadb-server php php-mysql php-pgsql php-pear php-gd  \
	&& apt-get clean  \
	&& rm -rf /var/lib/apt/lists/*\
	&& echo mariadb-server mysql-server/root_password password vulnerables | debconf-set-selections  \
	&& echo mariadb-server mysql-server/root_password_again password vulnerables | debconf-set-selections  
COPY php.ini /etc/php5/apache2/php.ini
COPY . /var/www/html/
COPY config/config.inc.php /var/www/html/config/
RUN chown www-data:www-data -R /var/www/html  \
	&& rm /var/www/html/index.html
RUN service mysql start  \
	&& sleep 3  \
	&& mysql -uroot -pvulnerables -e "CREATE USER app@localhost IDENTIFIED BY 'vulnerables';CREATE DATABASE dvwa;GRANT ALL privileges ON dvwa.* TO 'app'@localhost;"
EXPOSE 80
COPY main.sh / 
ENTRYPOINT ["/main.sh"]
