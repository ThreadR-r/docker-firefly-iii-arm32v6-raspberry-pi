# docker-firefly-iii

`
sudo docker rm -f firefly ;sudo docker run -d  --name firefly --network my-bridge -p 8880:80 -e FF_DB_HOST=postgres -e FF_DB_NAME=test -e FF_DB_USER=postgres -e FF_DB_PASSWORD=pass -e FF_DB_CONNECTION=pgsql -e FF_DB_PORT=5432 -e INIT_DATABASE=yes myfirefly
`
