FROM arm32v6/alpine:latest
COPY qemu-arm-static /usr/bin/

ENV FF_VERSION 4.8.2

ENV APP_ENV=local

# See also: https://github.com/JC5/firefly-iii-base-image

ENV FIREFLY_PATH=/var/www/localhost/htdocs/firefly COMPOSER_ALLOW_SUPERUSER=1

RUN    apk update && apk add --no-cache  \
    php7 \
    php7-fpm \
    php7-openssl \
    php7-mbstring \
    php7-json \
    php7-phar \
    php7-zlib \
    php7-zip \
    php7-bcmath \
    php7-intl \
    php7-curl \
    php7-session \
    php7-ctype \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-tokenizer \
    php7-fileinfo \
    php7-gd \
    php7-simplexml \
    php7-xml \
    php7-ldap \
    php7-iconv \
    php7-dom \
    supervisor \
    gettext \
    curl \
    nginx \
    tzdata && \
   mkdir -p $FIREFLY_PATH /run/nginx && \
   curl -sSL https://github.com/firefly-iii/firefly-iii/archive/${FF_VERSION}.tar.gz | tar xz -C $FIREFLY_PATH --strip-components=1 && \
   cd $FIREFLY_PATH && \
   curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
   composer install --prefer-dist --no-dev --no-scripts && \
   find /var/www/localhost/htdocs/ -type d -exec chmod 770 {} \; && \
   find /var/www/localhost/htdocs/ -type f -exec chmod 660 {} \; && \
   chown -R nginx:nobody /var/www/localhost/htdocs/ && \
   chmod +x $FIREFLY_PATH/.deploy/docker/entrypoint.sh
 

COPY custom.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /tmp/

WORKDIR $FIREFLY_PATH

# Create volumes
VOLUME $FIREFLY_PATH/storage/export $FIREFLY_PATH/storage/upload


EXPOSE 80

RUN sed -i 's/chown -R www-data:www-data -R $FIREFLY_PATH/chown -R nginx:nobody $FIREFLY_PATH/g' ${FIREFLY_PATH}/.deploy/docker/entrypoint.sh && \
    sed -i 's/exec apache2-foreground/\/usr\/bin\/supervisord -c \/tmp\/supervisord.conf/g' ${FIREFLY_PATH}/.deploy/docker/entrypoint.sh && \
    sed -i 's/#!\/bin\/bash/#!\/usr\/bin\/env sh/g' ${FIREFLY_PATH}/.deploy/docker/entrypoint.sh && \
    sed -i 's/echo \"Now in entrypoint.sh for Firefly III\"/echo \"Now in entrypoint.sh for Firefly III\" \&\& env > "${FIREFLY_PATH}"\/.env/g' ${FIREFLY_PATH}/.deploy/docker/entrypoint.sh


ENTRYPOINT $FIREFLY_PATH/.deploy/docker/entrypoint.sh

LABEL url=https://github.com/firefly-iii/firefly-iii/
LABEL version=${FF_VERSION}

