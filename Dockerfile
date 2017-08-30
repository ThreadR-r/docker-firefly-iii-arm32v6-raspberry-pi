FROM alpine:latest

RUN apk update && apk upgrade && apk add --no-cache gettext bash curl \
    php7 php7-fpm php7-openssl php7-mbstring php7-json php7-phar php7-zlib php7-zip php7-bcmath php7-intl php7-curl php7-session  php7-ctype php7-pdo_mysql php7-tokenizer \
    nginx \
    supervisor

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer && \
  curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig && \
  php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" && \
  chmod +x /tmp/composer-setup.php && \
  php /tmp/composer-setup.php && \
  mv composer.phar /usr/local/bin/composer && \
  rm -f /tmp/composer-setup.{php,sig}

# RUN mkdir -p  /var/www/localhost/htdocs/firefly

RUN curl -sL `curl -s https://api.github.com/repos/firefly-iii/firefly-iii/releases/latest | grep tarball_url | head -n 1 | cut -d '"' -f 4`  | tar xz -C /var/www/localhost/htdocs/firefly --strip-components=1  && echo "<?php phpinfo(); error_reporting(E_ALL); ini_set('display_errors', '1');?>" > /var/www/localhost/htdocs/index.php && echo "ahoj" > /var/www/localhost/htdocs/index.html

RUN cd /var/www/localhost/htdocs/firefly && composer install --no-scripts --no-dev


RUN mkdir -p /run/nginx && rm -rf  /etc/nginx/conf.d/default.conf

RUN  echo "<?php phpinfo(); ?>" > /var/www/localhost/htdocs/phpinfo.php

ADD vhost.conf /etc/nginx/conf.d/

USER root

RUN    find /var/www/localhost/htdocs/ -type d -exec chmod 770 {} \; && find /var/www/localhost/htdocs/ -type f -exec chmod 660 {} \;

ADD entrypoint.sh /var/www/localhost/htdocs/firefly/

EXPOSE 80

RUN chown -R nginx:nobody  /var/www/localhost/htdocs/

RUN chown root:root /var/www/localhost/htdocs/firefly/entrypoint.sh ; chmod 777 /var/www/localhost/htdocs/firefly/entrypoint.sh ; chmod +x /var/www/localhost/htdocs/firefly/entrypoint.sh

COPY  supervisord.conf /tmp/supervisord.conf

WORKDIR /var/www/localhost/htdocs/firefly/

ENTRYPOINT ["./entrypoint.sh"]
