#!/bin/bash
# upstream tarballs include ./ojs-${OJS_VERSION}/ so this gives us /var/www/ojs
#curl -o ojs.tar.gz -SL http://pkp.sfu.ca/ojs/download/ojs-${OJS_VERSION}.tar.gz \
#	&& tar -xzf ojs.tar.gz -C /var/www \
#	&& rm ojs.tar.gz \
#        && mv /var/www/ojs-${OJS_VERSION} /var/www/ojs \
#	&& chown -R www-data:www-data /var/www/ojs

# Cloning and Cleaning OJS and PKP-LIB git repositories
if [ ! -f /var/www/ojs/config.inc.php ]; then
    git config --global url.https://.insteadOf git:// \
    && git clone -v --recursive --progress https://github.com/pkp/ojs.git /var/www/ojs \
    && cd /var/www/ojs \
    && git fetch origin \
    && git checkout -f remotes/origin/${OJS_VERSION} -b ${OJS_VERSION} \
    && git submodule update --init --recursive;

    # Install composer
    curl -sS https://getcomposer.org/installer | php

    pushd lib/pkp \
    && php ../../composer.phar update;
    popd;

    pushd plugins/paymethod/paypal \
    && php ../../../composer.phar update;
    popd;

    pushd plugins/generic/citationStyleLanguage \
    && php ../../../composer.phar update;
    popd;

    cp config.TEMPLATE.inc.php config.inc.php
    chown -R www-data:www-data /var/www/ojs
fi

# creating a directory to save uploaded files.
mkdir /var/www/files \
    && chown -R www-data:www-data /var/www/files

sed -i -e "s/host = localhost/host = ${OJS_DB_HOST}/g" /var/www/ojs/config.inc.php
sed -i -e "s/username = ojs/username = ${OJS_DB_USER}/g" /var/www/ojs/config.inc.php
sed -i -e "s/password = ojs/password = ${OJS_DB_PASSWORD}/g" /var/www/ojs/config.inc.php
sed -i -e "s/name = ojs/name = ${OJS_DB_NAME}/g" /var/www/ojs/config.inc.php

sed -i -e "s/\/var\/www\/html/\/var\/www\/ojs/g" /etc/apache2/sites-available/000-default.conf

if [ -z "$SERVERNAME" ]
then
    echo "SERVERNAME not provided, virtualhost will be created without a hostname.";
	sed -i -e "/ServerName www.example.com/d";
else
    echo "${SERVERNAME} will be used to create virtualhost";
    sed -i -e "s/www.example.com/${SERVERNAME}/g" /etc/apache2/sites-available/000-default.conf;
fi

sed -i -e "s/\/var\/log\/apache2/${APACHE_LOG_DIR}/g" /etc/apache2/sites-available/000-default.conf
sed -i -e "s/error.log/%Y-%m-%d+${LOG_NAME}-error.log/g" /etc/apache2/sites-available/000-default.conf
sed -i -e "s/access.log/%Y-%m-%d+${LOG_NAME}.log/g" /etc/apache2/sites-available/000-default.conf

# Start the cron service in the background.
cron -f &
echo "[OJS Startup] Started cron"

# Run the apache process in the foreground as in the php image
echo "[OJS Startup] Starting apache..."
apache2-foreground
