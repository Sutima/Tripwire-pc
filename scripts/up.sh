docker compose up -d traefik php-fpm mysql
sleep 5
docker compose up -d nginx adminer
