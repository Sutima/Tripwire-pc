#!/usr/bin/bash
# Ensure .env file exists
if [ ! -f .env ]; then
  echo ".env file not found. Spawning and Exiting."
  cp example.env .env
  chmod 600 .env
  echo "Please fill in the required values in .env file."
  exit 1
fi

# Copy example files
cp db.inc.docker.example.php db.inc.php
cp config.example.php config.php

mkdir -p traefik-data
touch traefik-data/acme.json
chmod 600 traefik-data/acme.json

# Extract values from .env
ADM_EMAIL=$(grep '^ADM_EMAIL=' .env | cut -d '=' -f2)
TRDOMAIN=$(grep '^TRDOMAIN=' .env | cut -d '=' -f2)
MYSQL_ROOT_PASSWORD=$(grep '^MYSQL_ROOT_PASSWORD=' .env | cut -d '=' -f2)
MYSQL_USER=$(grep '^MYSQL_USER=' .env | cut -d '=' -f2)
MYSQL_PASSWORD=$(grep '^MYSQL_PASSWORD=' .env | cut -d '=' -f2)
SSO_SECRET=$(grep '^SSO_SECRET=' .env | cut -d '=' -f2)
SSO_CLIENT=$(grep '^SSO_CLIENT=' .env | cut -d '=' -f2)

# Check for missing variables
if [ -z "$ADM_EMAIL" ] || [ -z "$TRDOMAIN" ] || [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$SSO_SECRET" ] || [ -z "$SSO_CLIENT" ]; then
    echo "One or more required variables are missing in the .env file. Please check and try again."
    exit 1
fi

# Escape special characters for sed
MYSQL_USER_ESCAPED=$(printf '%s\n' "$MYSQL_USER" | sed 's/[&/\]/\\&/g')
MYSQL_PASSWORD_ESCAPED=$(printf '%s\n' "$MYSQL_PASSWORD" | sed 's/[&/\]/\\&/g')

# Replace placeholders in db.inc.php
sed -i -e "s/usernamefromdockercompose/$MYSQL_USER_ESCAPED/g; s/userpasswordfromdockercompose/$MYSQL_PASSWORD_ESCAPED/g" ./db.inc.php

# Replace placeholders in config.php
sed -i -e "s/\(your domain\|yourdomain\)/$TRDOMAIN/g; s/adminEmail@example.com/$ADM_EMAIL/g; s/client/$SSO_CLIENT/g; s/secret/$SSO_SECRET/g; s/yourdomain.com/$TRDOMAIN/g" ./config.php

# Update crontab
crontab -l | cat - crontab-tw.txt >/tmp/crontab.txt && crontab /tmp/crontab.txt