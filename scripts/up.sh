docker compose --env-file .env up -d mysql traefik php-fpm nginx
sleep 5
docker compose --env-file .env up -d  killboard