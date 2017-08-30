#!/bin/bash

cat .env.docker | envsubst > .env

if [ "${INIT_DATABASE:="no"}" = "yes" ]; then
       until php artisan firefly:verify &>/dev/null
       do
               echo "waiting mysql"
               sleep 10
       done
       php artisan migrate:refresh --seed --force
fi

/usr/bin/supervisord -c /tmp/supervisord.conf
