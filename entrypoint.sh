#!/bin/sh

if [ -z "${FF_DB_HOST+x}" ] || [ -z "${FF_DB_NAME+x}" ] || [ -z "${FF_DB_USER+x}" ] || [ -z "${FF_DB_PASSWORD+x}" ];then
    
   echo "You must set env variables to connect to db !"
   exit 1

fi

sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=${FF_DB_CONNECTION}/g' .env.docker
sed -i 's/DB_PORT=3306/DB_CONNECTION=${FF_DB_PORT}/g' .env.docker


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

exec $@
