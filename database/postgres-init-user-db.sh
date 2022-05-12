#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE USER $DB_USER PASSWORD '$DB_USER_PASSWORD';
  CREATE DATABASE $DB_NAME;
  GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOSQL

for script in $(/usr/bin/find /datamodel -type f -iname '*.sql' | sort); do
  echo "Running $script";
  POSTGRES_PASSWORD="$DB_USER_PASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -w -f "$script"
done
