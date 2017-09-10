#!/bin/sh

cat .env.docker | envsubst > .env

if [ "${INIT_DATABASE:="no"}" = "yes" ]; then
       until php artisan firefly:verify &>/dev/null
       do
               echo "waiting mysql"
               sleep 10
       done
       echo "php artisan migrate:refresh --seed --force" >> /dev/stdout
       php artisan migrate:refresh --seed --force
fi

exec "$@"
