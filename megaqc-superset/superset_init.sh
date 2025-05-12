#!/usr/bin/env bash
set -e

# Set a default Trino host if not provided
TRINO_HOST=${TRINO_HOST:-trino-server}
TRINO_PORT=${TRINO_PORT:-8080}
TRINO_USER=${TRINO_USER:-admin}
TRINO_CATALOG=${TRINO_CATALOG:-iceberg}

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

  # Create Trino database connection using environment variables
  echo "Connecting to Trino at ${TRINO_HOST}:${TRINO_PORT}..."
  superset set-database-uri \
    --database-name "Trino" \
    --uri "trino://${TRINO_USER}@${TRINO_HOST}:${TRINO_PORT}/${TRINO_CATALOG}"

  touch "$HOME/.initialized"
fi

exec superset run --host 0.0.0.0 --port 8080