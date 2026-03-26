# README

Some things have changed, read carefully
The landing page twitter feed won't work since the one I used requires a private token, I will have to find a new way to do it later.

## Tripwire - EVE Online wormhole mapping web tool

- MIT license
- Fork of [Tripwire](https://bitbucket.org/daimian/tripwire/src)

### Table of contents

- Eve SSO instructions
- Bare metal setup
- Docker compose setup

### EVE SSO

Create an EVE developer application via [https://developers.eveonline.com/applications](https://developers.eveonline.com/applications)
EVE SSO `Callback URL` should be: `https://your-domain.com/index.php?mode=sso`

- Use the following scopes:
- esi-location.read_location.v1
- esi-location.read_ship_type.v1
- esi-ui.open_window.v1
- esi-ui.write_waypoint.v1
- esi-characters.read_corporation_roles.v1
- esi-location.read_online.v1
- esi-characters.read_titles.v1
- esi-search.search_structures.v1

## Setup guide for Linux

**These instructions might be a tad outdated, feel free to update them.**

Requirements:

- PHP7+ (older requires polyfill for public/login.php as documented in that file)
- php-mbstring must be installed
- MySQL (or some flavor of MySQL - needed because database EVENTS)
- A `my.cnf` MySQL config file example is located in`.docker/mysql/my.cnf`
- The`sql_mode` and`event_scheduler` my.cnf lines are important, make sure you have them in your my.cnf file & reboot MySQL
- CRON or some other scheduler to execute PHP scripts

Setup:

- Create a`tripwire` database using the export located in`.docker/mysql/tripwire.sql`
- For development: create an EVE dump database, define it's name later in`config.php`. Download from: [https://www.fuzzwork.co.uk/dump/](https://www.fuzzwork.co.uk/dump/) To download the latest use the following link: [https://www.fuzzwork.co.uk/dump/mysql-latest.tar.bz2](https://www.fuzzwork.co.uk/dump/mysql-latest.tar.bz2). You do not need a copy of the SDE to run Tripwire (since 1.21).
- Clone the Tripwire repo to where you are going to serve to the public OR manually download repo and copy files yourself
- Copy`db.inc.example.php` to`db.inc.php` - modify file per your setup
- Copy`config.example.php` to`config.php` - modify file per your setup
- Create an EVE developer application via [https://developers.eveonline.com/applications](https://developers.eveonline.com/applications)
- EVE SSO `Callback URL` should be:`https://your-domain.com/index.php?mode=sso`
- Use the following scopes:
  esi-location.read_location.v1
  esi-location.read_ship_type.v1
  esi-ui.open_window.v1
  esi-ui.write_waypoint.v1
  esi-characters.read_corporation_roles.v1
  esi-location.read_online.v1
  esi-characters.read_titles.v1
  esi-search.search_structures.v1
- Settings go in the`config.php` file
- Modify your web server to serve Tripwire from the`tripwire/public` folder so the files like`config.php` and`db.inc.php` are not accessible via URL
- Setup a CRON or schedule for`system_activity.cron.php` to run at the top of every hour. CRON:`0 * * * * php /dir/to/system_activity.cron.php`
- Setup a CRON or schedule for`account_update.cron.php` to run every 3 minutes or however often you want to check for corporation changes. CRON:`*/3 * * * * php /dir/to/account_update.cron.php`
- If you are using SELinux: Tripwire needs access to the 'cache' directory inside the deployment directory, usually /var/www/tripwire. You need to make this a write-access directory via SELinux labelling:`semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/tripwire/cache(/.*)?"` - then relabel the directory`restorecon -R -v /var/www/tripwire`

## Setup guide for Docker

- Install Docker for your environment: [https://www.docker.com/](https://www.docker.com/)
- Setup Developer application on Eve developers
- Configure your domain registrar with a record pointed to the vm you are using -- ensure port 80/443 are open (80 can be closed after traefik setup)
- Clone repo and change directory into it

### QUICK SETUP

There are quick setup scripts in the scripts folder.

#### gen.sh

Either use the `./scripts/gen.sh` script, it will do the setup based off your .env file if you have one, or make an .env file for you to fill in if there isn't one already. Then build build `docker compose build`and run `docker compose --env-file=.env up -d`.

#### setup.sh

A setup script is provided `./scripts/setup.sh`
This script will request all needed information and modify settings, then offer the option to start the build
Once complete, your tripwire instance will be up and running.
Don't forget to give perms to the cache and for the entrypoint.
`docker compose run php-fpm chown -R www-data:www-data /opt/app/cache`

**After either of these methods you need to run `docker compose run php-fpm chown -R www-data:www-data /opt/app/cache` after the container is up and running.**

### Manual Setup - no script setup

There are 2 docker compose files one that has traefik included if and one that does not in-case you're already have proxies setup, simply copy over the one you prefer. For traefik: `cp docker-compose-traefik.yaml docker-compose.yml` or for NGINX: `cp docker-compose-nginx.yml docker-compose.yml`

- Copy db.inc.docker.example.php to db.inc.php `cp db.inc.docker.example.php db.inc.php`
- Copy config.example.php to config.php `cp config.example.php config.php`
- Copy .env.example `cp .env.example .env`
- Modify the constants with your own settings in all of those files
- Prep traefik acme file
- `chmod +x .docker/python/entrypoint.sh`
- docker compose run php-fpm chown -R www-data:www-data /opt/app/cache
- To get the thera chain you need to chown the cache folder in the container. After the containers are up and running, run `docker compose run php-fpm chown -R www-data:www-data /opt/app/cache`

For non script installs you need to edit the the following files `.env`, `db.inc.php`, `config.php`.

#### .env

Edit the env to reflect your own setup.

```yml
# A Mail address for cert's and headers
ADM_EMAIL=admin@example.com
# Your domain name for tripwire
TRDOMAIN=example.com
# Mysql root pass word
MYSQL_ROOT_PASSWORD=rootmysqlpassword
# A non-root mysql user
MYSQL_USER=nonrootuse
# Password for the non-root user
MYSQL_PASSWORD=mysqlpasswor
# EVE SSO Client and Secret's
SSO_CLIENT=ssoclienthere
SSO_SECRET=ssosekrithere
```

#### db.inc.php

Replace the `usernamefromenv` with the same username you put into `MYSQL_USER`in the .env and the replace the `userpasswordfromenv`with the same password you put into `MYSQL_PASSWORD`in the .env.

#### config.php

Make sure that:

- `EVE_DUMP` matches SDE_DB in docker-compose.yml
- `CDN_DOMAIN` this should match the domain name in your docker-compose unless you're running a CDN.
- `EVE_SSO_CLIENT`, `EVE_SSO_SECRET`, and `EVE_SSO_REDIRECT` should be updated to match the EVE SSO application

#### Traefik Acme

Prepping Traefik.

- `mkdir -p traefik-data`
- `touch traefik-data/acme.json`
- `chmod 600 traefik-data/acme.json`

#### CRON

Adding a cron schedule for account updates and system activity info.

`crontab -l | cat - crontab-tw.txt >/tmp/crontab.txt && crontab /tmp/crontab.txt`

#### DOCKER BUILD

The first time you run it will initialize the sde DB so it might take a bit of time `docker compose --env-file=.env up -d --build` then run `docker compose run php-fpm chown -R www-data:www-data /opt/app/cache` to sort out the permissions for the eve-scout cache.

To view logs run `docker compose logs -tf`

### Contribution guidelines

- Base off of production or development
- Create PRs into development
- Look over issues, branches or get with me to ensure it isn't already being worked on

### Who do I talk to?

- Me, (`Devlin Shardo` in-game) Sutima for anything related to this fork.
- Astriania / Kariyo Astrien (Main contributor/maintainer of main tripwire repo)
- Tripwire Public in-game channel
- Discord: [https://discord.gg/xjFkJAx](https://discord.gg/xjFkJAx)
- Josh Glassmaker AKA Daimian Mercer (Creator)
