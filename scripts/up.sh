docker compose --env-file .env up -d mysql traefik php-fpm
sleep 5
docker compose --env-file .env up -d nginx adminer killboard