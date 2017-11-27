FROM php:5.6-apache

MAINTAINER Rondineli Saad <rondineli.saad@scielo.org>

RUN a2enmod rewrite expires

# install the PHP extensions we need
RUN apt-get -qqy update \
    && apt-get install -qqy libpng12-dev \
                            libjpeg-dev \
                            libmcrypt-dev \
                            libxml2-dev \
                            libxslt-dev \
			    cron \
			    logrotate \
			    git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd \
                              mysqli \
                              mysql \
                              opcache \
			      mcrypt \
			      soap \
			      xsl \
			      zip

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.max_file_size=0'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# enable mod_rewrite
RUN a2enmod rewrite

WORKDIR /var/www/

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

# Add crontab running runSheduledTasks.php
COPY ojs-crontab.conf /ojs-crontab.conf
RUN sed -i 's:INSTALL_DIR:'`pwd`':' /ojs-crontab.conf \
    && sed -i 's:FILES_DIR:/var/www/ojs/files:' /ojs-crontab.conf \
    && echo "$(cat /ojs-crontab.conf)" \
    # Use the crontab file
    && crontab /ojs-crontab.conf \
    && touch /var/log/cron.log

EXPOSE 80

# Add startup script to the container.
COPY ojs-startup.sh /ojs-startup.sh

# Execute the containers startup script which will start many processes/services
CMD ["/bin/bash", "/ojs-startup.sh"]
