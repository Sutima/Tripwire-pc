#!/usr/bin/bash

# Copy example files
cp db.inc.docker.example.php db.inc.php
cp config.example.php config.php

# Ensure .env file exists
if [ ! -f .env ]; then
  echo ".env file not found. Exiting."
  exit 1
fi

# Extract values from .env
ADM_EMAIL=$(grep '^ADM_EMAIL=' .env | cut -d '=' -f2)
TRDOMAIN=$(grep '^TRDOMAIN=' .env | cut -d '=' -f2)
MYSQL_ROOT_PASSWORD=$(grep '^MYSQL_ROOT_PASSWORD=' .env | cut -d '=' -f2)
MYSQL_USER=$(grep '^MYSQL_USER=' .env | cut -d '=' -f2)
MYSQL_PASSWORD=$(grep '^MYSQL_PASSWORD=' .env | cut -d '=' -f2)
SSO_SECRET=$(grep '^SSO_SECRET=' .env | cut -d '=' -f2)
SSO_CLIENT=$(grep '^SSO_CLIENT=' .env | cut -d '=' -f2) # Added extraction for SSO_CLIENT

# Replace placeholders in db.inc.php
sed -i -e "s/usernamefromdockercompose/$MYSQL_USER/g; s/userpasswordfromdockercompose/$MYSQL_PASSWORD/g" ./db.inc.php

# Replace placeholders in config.php
sed -i -e "s/\(your domain\|yourdomain\)/$TRDOMAIN/g; s/adminEmail@example.com/$ADM_EMAIL/g; s/client/$SSO_CLIENT/g; s/secret/$SSO_SECRET/g" ./config.php