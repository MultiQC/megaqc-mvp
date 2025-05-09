#!/usr/bin/env bash
set -e

# The base image runs as user "superset"; HOME=/app/superset_home
if [ ! -f "$HOME/.initialized" ]; then
  superset fab create-admin \
      --username admin \
      --firstname Vladislav \
      --lastname Savelyev \
      --email vladislav.sav@gmail.com \
      --password "${PASSWORD}"
  superset db upgrade
  superset init              # 🔑 create roles & permissions

  touch "$HOME/.initialized"
fi

exec superset run --host 0.0.0.0 --port 8088