FROM alpine:latest

ENV FF_VERSION 4.6.5

ENV FF_APP_ENV=production
ENV FF_DB_HOST=mariadb
ENV FF_DB_NAME=firefly
ENV FF_DB_USER=firefly
ENV FF_DB_PASSWORD=pass
ENV FF_APP_KEY=SomeRandomStringOf32CharsExactly

RUN apk update && apk upgrade && apk add --no-cache gettext curl \
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
    php7-tokenizer \
    supervisor \
    lighttpd

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer && \
  curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig && \
  php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" && \
  chmod +x /tmp/composer-setup.php && \
  php /tmp/composer-setup.php && \
  mv composer.phar /usr/local/bin/composer && \
  rm -f /tmp/composer-setup.{php,sig}

RUN mkdir -p /var/www/localhost/htdocs/firefly && curl -L https://github.com/firefly-iii/firefly-iii/archive/${FF_VERSION}.tar.gz | tar xz -C /var/www/localhost/htdocs/firefly --strip-components=1 && cd /var/www/localhost/htdocs/firefly && composer install --no-scripts --no-dev
RUN find /var/www/localhost/htdocs/ -type d -exec chmod 770 {} \; && find /var/www/localhost/htdocs/ -type f -exec chmod 660 {} \; && chown -R lighttpd:nobody  /var/www/localhost/htdocs/

COPY entrypoint.sh /root/
COPY lighttpd.custom.conf /etc/lighttpd/
COPY supervisord.conf /tmp/

RUN chmod +x /root/entrypoint.sh && chmod o+w /dev/stdout

RUN  ln -sf /dev/stdout /var/log/lighttpd/access.log && ln -sf /dev/stdout /var/log/lighttpd/error.log

EXPOSE 80

WORKDIR  /var/www/localhost/htdocs/firefly

RUN ls -lha /root/

ENTRYPOINT ["/root/entrypoint.sh"]

CMD /usr/bin/supervisord -c /tmp/supervisord.conf
