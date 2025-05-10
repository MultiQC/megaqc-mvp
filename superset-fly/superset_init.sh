#!/usr/bin/env bash
set -e

# The base image runs as user "superset"; HOME=/app/superset_home
if [ ! -f "$HOME/.initialized" ]; then
  superset fab create-admin \
      --username admin \
      --firstname Vladislav \
      --lastname Savelyev \
      --email vladislav.sav@gmail.com \
      --password "${PASSWORD:-admin}"
  superset db upgrade
  superset init              # 🔑 create roles & permissions

  # Create Trino database connection
  superset set-database-uri \
    --database-name "Trino" \
    --uri "trino://admin@trino-server:8080/iceberg"

  touch "$HOME/.initialized"
fi

exec superset run --host 0.0.0.0 --port 8080