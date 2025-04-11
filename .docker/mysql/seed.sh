#!/usr/bin/env bash
set -euo pipefail

echo "[SEED] Starting Tripwire + fuzzworks SDE seed..."

DB_HOST="${DB_HOST:-mysql}"
DB_PORT="${DB_PORT:-3306}"
DB_ROOT_USER="${DB_ROOT_USER:-root}"
DB_ROOT_PASS="${DB_ROOT_PASS:-}"
TRIPWIRE_DB="${TRIPWIRE_DB:-tripwire_database}"
SDE_DB="${SDE_DB:-eve_dump}"

echo "[SEED] DB_HOST=$DB_HOST; DB_PORT=$DB_PORT; TRIPWIRE_DB=$TRIPWIRE_DB; SDE_DB=$SDE_DB"

###############################################################################
# 1) Wait for MySQL to be reachable
###############################################################################
MAX_WAIT=30
echo "[SEED] Waiting up to $MAX_WAIT seconds for MySQL ($DB_HOST:$DB_PORT) to accept connections..."
for i in $(seq 1 "$MAX_WAIT"); do
  if mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ROOT_USER" -p"$DB_ROOT_PASS" --silent; then
    echo "[SEED] MySQL is available!"
    break
  fi
  echo -n "."
  sleep 1
done

###############################################################################
# 2) Import the Tripwire schema
###############################################################################
if [ -f ./tripwire.sql ]; then
  echo "[SEED] Checking if we need to create Tripwire DB schema from tripwire.sql..."
  echo "[SEED] Creating $TRIPWIRE_DB and loading ./tripwire.sql..."

  # Create DB if not exists:
  mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ROOT_USER" -p"$DB_ROOT_PASS" \
        -e "CREATE DATABASE IF NOT EXISTS \`${TRIPWIRE_DB}\`;"

  # Load the .sql
  mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ROOT_USER" -p"$DB_ROOT_PASS" \
        "$TRIPWIRE_DB" < ./tripwire.sql
  echo "[SEED] Tripwire schema imported into $TRIPWIRE_DB!"
else
  echo "[SEED] tripwire.sql not found? Skipping."
fi

###############################################################################
# 3) Optionally fetch fuzzworks SDE & import it
###############################################################################
echo "[SEED] Checking Fuzzworks SDE logic..."

if [ -z "${SDE_DB:-}" ]; then
  echo "[SEED] SDE_DB is empty? Skipping SDE import."
  exit 0
fi


echo "[SEED] Creating $SDE_DB if not exists..."
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ROOT_USER" -p"$DB_ROOT_PASS" \
      -e "CREATE DATABASE IF NOT EXISTS \`${SDE_DB}\`;"

echo "[SEED] Downloading fuzzworks SDE..."
mkdir -p /tmp/eve_dump
cd /tmp
wget --no-verbose https://www.fuzzwork.co.uk/dump/mysql-latest.tar.bz2
tar jxf mysql-latest.tar.bz2 -C /tmp/eve_dump --strip-components 1
echo "[SEED] Importing SDE .sql into $SDE_DB ..."
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_ROOT_USER" -p"$DB_ROOT_PASS" \
      "$SDE_DB" < /tmp/eve_dump/*.sql
echo "[SEED] SDE import complete!"

echo "[SEED] All done!"
exit 0

