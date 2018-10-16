#!/bin/bash

HAS_BEEN_CONFIGURED_LOCK='/var/www/ojs/AUTO_CONFIGURED.lock'

if [ ! -f ${HAS_BEEN_CONFIGURED_LOCK} ]; then
  sed -i -e "s/driver = mysql/driver = mysqli/g" /var/www/ojs/config.inc.php # mysql is not available in > php7
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

  touch ${HAS_BEEN_CONFIGURED_LOCK};
fi

# Start the cron service in the background.
cron -f &
echo "[OJS Startup] Started cron";

# Run the apache process in the foreground as in the php image
echo "[OJS Startup] Starting apache... You'll be good to go after this..."
apache2-foreground
