#!/bin/bash

# Uncomment to use tarballs from pkp downloads like http://pkp.sfu.ca/ojs/download/ojs-3.1.2.tar.gz
# upstream tarballs include ./ojs-${OJS_VERSION}/ so this gives us /var/www/ojs
echo "Fetching ojs from tarball directly"
curl -o ojs.tar.gz -SL http://pkp.sfu.ca/ojs/download/ojs-${OJS_VERSION}.tar.gz \
	&& tar -xvf ojs.tar.gz -C /var/www \
	&& rm ojs.tar.gz \
       && mv /var/www/ojs-${OJS_VERSION} /var/www/ojs \
	&& chown -R www-data:www-data /var/www/ojs


# Cloning and Cleaning OJS and PKP-LIB git repositories if not already using
# a tarball
if [ ! -f /var/www/ojs/config.inc.php ]; then
    git config --global url.https://.insteadOf git:// \
    && git clone --depth 1 --recurse-submodules -j8 --progress https://github.com/pkp/ojs.git /var/www/ojs \
    && cd /var/www/ojs \
    && git fetch origin \
    && git checkout -f remotes/origin/${OJS_VERSION} -b ${OJS_VERSION}  --depth 1 \
    && git submodule update -j8 --init --recursive;

    # Install composer
    curl -sS https://getcomposer.org/installer | php

    echo "Installing pkp lib composer dependencies now.";
    pushd lib/pkp \
    && php ../../composer.phar install;
    popd;

    echo "Installing paypal library composer dependencies now.";
    pushd plugins/paymethod/paypal \
    && php ../../../composer.phar install;
    popd;

    pushd plugins/generic/citationStyleLanguage \
    && php ../../../composer.phar install;
    popd;

    echo "Copying config.TEMPLATE";
    cp config.TEMPLATE.inc.php config.inc.php

    chown -R www-data:www-data /var/www/ojs
fi

# creating a directory to save uploaded files.
mkdir -p /var/www/files \
    && chown -R www-data:www-data /var/www/files
