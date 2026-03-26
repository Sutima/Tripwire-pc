#!/bin/bash

########################################################################
#                                                                      #
#                   Tripwire Docker Installer Script                   #
#                                                                      #
########################################################################

function getvars {

  while true;do

    echo
    read -p "Please enter the Traefik email: " ADM_EMAIL
    echo ""
    read -p "Please enter the domain name for tripwire: " TRDOMAIN
    echo ""
    read -p "Please enter the mysql ROOT password to be set: " MYSQL_ROOT_PASSWO
    read -p "Please enter the mysql USER name to be created: " MYSQL_USER
    read -p "Please enter the mysql USER password to be set: " MYSQL_PASSWORD
    echo ""
    read -p "What is the EVE SSE clientID?: " SSO_CLIENT
    read -p "What is the EVE SSE secretID?: " SSO_SECRET
    echo ""
    echo -e "\n\nHere is what you have entered:"
    echo "Traefik email   : $ADM_EMAIL"
    echo "Tripwire domain : $TRDOMAIN"
    echo "mysql root pass : $MYSQL_ROOT_PASSWO"
    echo "mysql user name : $MYSQL_USER"
    echo "mysql user pass : $MYSQL_PASSWORD"
    echo "EVE SSO clientID: $SSO_CLIENT"
    echo "EVE SSO secretID: $SSO_SECRET"
    echo ""
    read -p "Do you want to use Traek bundled with Tripwire? (yes/no) " yno
    case $yno in
      [Yy]*) cp ./docker-compose-traefik.yaml ./docker-compose.yml && echo "Using Traefik";;
      [Nn]*) cp ./docker-compose-nginx.yml ./docker-compose.yml && echo "Using My own proxy";;
          *) echo "Try again";;
    esac
    echo ""
    echo "Please check this information carefully." 
    echo ""
    echo "Please check this information carefully." 
    read -p "Is this all correct? (yes/no/abort) " yno
    case $yno in
      [Yy]*) dosetup;;
      [Nn]*) continue;;
      [Aa]*) exit 0;;
          *) echo "Try again";;
    esac
  done
}

function dosetup {

  #set up php files.
  cp db.inc.docker.example.php db.inc.php
  cp config.example.php config.php

  #write given variables to .env file
  echo "ADM_EMAIL=$ADM_EMAIL" >> .env
  echo "TRDOMAIN=$TRDOMAIN" >> .env
  echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" >> .env
  echo "MYSQL_USER=$MYSQL_USER" >> .env
  echo "MYSQL_PASSWORD=$MYSQL_PASSWORD" >> .env
  echo "SSO_CLIENT=$SSO_CLIENT" >> .env
  echo "SSO_SECRET=$SSO_SECRET" >> .env

  #set up config
  sed -i -e "s/usernamefromenv/$MYSQL_USER/g; s/userpasswordfromenv/$MYSQL_PASSWORD/g" ./db.inc.php
  sed -i -e "s/\(your domain\|yourdomain\)/$TRDOMAIN/g; s/adminEmail@example.com/$ADM_EMAIL/g; s/client/$SSO_CLIENT/g; s/secret/$SSO_SECRET/g; s/yourdomain.com/$TRDOMAIN/g" ./config.php

  #setup traefik
  mkdir -p traefik-data

  if [ -d traefik-data/acme.json ]; then
  echo "Error: traefik-data/acme.json exists as a directory. Removing it."
  rm -rf traefik-data/acme.json
fi

  touch traefik-data/acme.json
  chmod 600 traefik-data/acme.json
  # sort perms
  chmod +x .docker/python/entrypoint.sh

  #add crontab entries
  (crontab -l | grep -Fxvf crontab-tw.txt; cat crontab-tw.txt) | crontab -

  while true;do
      read -p "Would you like to build now? (yes/no) " yno
      case $yno in
          [Yy]*) dobuild;;
          [Nn]*) exit 0;;
              *) echo "Try again";;
      esac
  done
}

function dobuild {
  docker compose --env-file .env up -d --build
  exit
}
getvars

