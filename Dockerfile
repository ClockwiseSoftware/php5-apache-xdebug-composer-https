FROM php:5.6-apache

ENV APACHE_CONF_DIR=/etc/apache2

RUN apt-get update && \
	apt-get install -y libcurl4-gnutls-dev libmcrypt-dev libxml2-dev && \
	docker-php-ext-install -j$(nproc) iconv mcrypt pdo_mysql pcntl curl bcmath mbstring soap mysqli && \
	docker-php-ext-enable iconv mcrypt pdo_mysql pcntl curl bcmath mbstring soap mysqli

RUN cp /dev/null ${APACHE_CONF_DIR}/conf-available/other-vhosts-access-log.conf \
    && rm ${APACHE_CONF_DIR}/sites-enabled/000-default.conf ${APACHE_CONF_DIR}/sites-available/000-default.conf \
    && a2enmod rewrite php5

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host=docker_host" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer && \
    rm -rf /tmp/composer-setup.php

RUN apt-get install -y git zip
RUN a2enmod ssl

WORKDIR /var/www
COPY ./certificates/cert.crt /etc/apache2/ssl/server.crt
COPY ./certificates/cert.key /etc/apache2/ssl/server.key
COPY ./config/app.conf ${APACHE_CONF_DIR}/sites-enabled/app.conf
COPY ./config/php.ini /usr/local/etc/php/conf.d/php.ini
EXPOSE 80