# docker-firefly-iii

## Info:
Based on arm32v6/alpine:latest which make it compatible with Raspberry Pi Zero (||w)
This image use php7-fpm with nginx instead of apache2 in official image

## Usage:
`docker run -d --name fireflyiii \`  
`-p 80:80 \`  
`-e APP_KEY=SomeRandomStringOf32CharsExactly \`  
`-e DB_HOST=CHANGEME \`  
`-e DB_DATABASE=fireflyiii \`  
`-e DB_USERNAME=fireflyiii \`  
`-e DB_PASSWORD=CHANGEME \`  
`-e DB_CONNECTION=mysql \`  
`-e DB_PORT=3306 \`  
`-it threadrr/firefly-iii-arm32v6-raspberry-pi:latest`


Firefly-iii Official repository:
https://github.com/firefly-iii/firefly-iii
