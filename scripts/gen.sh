#!/usr/bin/bash
# Ensure .env file exists.
if [ ! -f .env ]; then
  echo ".env file not found. Spawning and Exiting."
  cp .env.example .env || { echo "Failed to copy .env.example to .env"; exit 1; }
  chmod 600 .env
  echo "Please fill in the required values in .env file."
  exit 1
fi

# Copy example files
cp db.inc.docker.example.php db.inc.php
cp config.example.php config.php

# Create traefik-data directory and acme.json file for traefik users.
mkdir -p traefik-data
if [ -d traefik-data/acme.json ]; then
  echo "Error: traefik-data/acme.json exists as a directory. Removing it."
  rm -rf traefik-data/acme.json
fi
touch traefik-data/acme.json
chmod 600 traefik-data/acme.json

# Extract values from .env
ADM_EMAIL=$(grep '^ADM_EMAIL=' .env | cut -d '=' -f2 | sed 's/^"\(.*\)"$/\1/')
TRDOMAIN=$(grep '^TRDOMAIN=' .env | cut -d '=' -f2 | sed 's/^"\(.*\)"$/\1/')
MYSQL_ROOT_PASSWORD=$(grep '^MYSQL_ROOT_PASSWORD=' .env | cut -d '=' -f2 | sed 's/^"\(.*\)"$/\1/')
MYSQL_USER=$(grep '^MYSQL_USER=' .env | cut -d '=' -f2 | sed 's/^"\(.*\)"$/\1/')
MYSQL_PASSWORD=$(grep '^MYSQL_PASSWORD=' .env | cut -d '=' -f2 | sed 's/^"\(.*\)"$/\1/')
SSO_SECRET=$(grep '^SSO_SECRET=' .env | cut -d '=' -f2 | sed 's/^"\(.*\)"$/\1/')
SSO_CLIENT=$(grep '^SSO_CLIENT=' .env | cut -d '=' -f2 | sed 's/^"\(.*\)"$/\1/')

# Check for missing variables
if [ -z "$ADM_EMAIL" ] || [ -z "$TRDOMAIN" ] || [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$SSO_SECRET" ] || [ -z "$SSO_CLIENT" ]; then
    echo "One or more required variables are missing in the .env file. Please check and try again."
    exit 1
fi

# Escape special characters for sed
MYSQL_USER_ESCAPED=$(printf '%s\n' "$MYSQL_USER" | sed 's/[&/\]/\\&/g')
MYSQL_PASSWORD_ESCAPED=$(printf '%s\n' "$MYSQL_PASSWORD" | sed 's/[&/\]/\\&/g')
ADM_EMAIL_ESCAPED=$(printf '%s\n' "$ADM_EMAIL" | sed 's/[&/\]/\\&/g')
TRDOMAIN_ESCAPED=$(printf '%s\n' "$TRDOMAIN" | sed 's/[&/\]/\\&/g')
SSO_CLIENT_ESCAPED=$(printf '%s\n' "$SSO_CLIENT" | sed 's/[&/\]/\\&/g')
SSO_SECRET_ESCAPED=$(printf '%s\n' "$SSO_SECRET" | sed 's/[&/\]/\\&/g')

# Replace placeholders in db.inc.php
sed -i -e "s/usernamefromdockercompose/$MYSQL_USER_ESCAPED/g; s/userpasswordfromdockercompose/$MYSQL_PASSWORD_ESCAPED/g" ./db.inc.php

# Replace placeholders in config.php
sed -i -e "s/\(your domain\|yourdomain\)/$TRDOMAIN/g; s/adminEmail@example.com/$ADM_EMAIL/g; s/client/$SSO_CLIENT/g; s/secret/$SSO_SECRET/g; s/yourdomain/$TRDOMAIN/g" ./config.php

# sort perms
chmod +x ./.docker/python/entrypoint.sh

# Update crontab
(crontab -l | grep -Fxvf crontab-tw.txt; cat crontab-tw.txt) | crontab -

read -p "Do you want to use Traek bundled with Tripwire? (yes/no) " yno
case $yno in
  [Yy]*) cp ./docker-compose-traefik.yaml ./docker-compose.yml && echo "Using Traefik";;
  [Nn]*) cp ./docker-compose-nginx.yml ./docker-compose.yml && echo "Using My own proxy";;
      *) echo "Try again";;
esac
echo "Have fun"