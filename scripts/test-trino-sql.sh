#!/bin/bash
# Test queries to diagnose Trino functionality

# Set the target based on argument (local or fly)
TARGET=${1:-local}

# Functions for both local and Fly.io targets
run_local_query() {
  echo -e "=== Running query: $1 ==="
  docker exec trino-server trino --execute "$1"
  echo -e "\n"
}

# Make the appropriate help text
if [ "$TARGET" = "local" ]; then
  echo "Testing Trino queries on local Docker container..."
  echo "=================================================="
  
  # Basic connectivity
  run_local_query "SELECT 1 AS test"
  
  # List catalogs
  run_local_query "SHOW CATALOGS"
  
  # Iceberg catalog and schemas
  run_local_query "SHOW SCHEMAS FROM iceberg"
  
  # System tables diagnostic info
  run_local_query "SELECT * FROM system.runtime.nodes"
  run_local_query "SELECT * FROM system.metadata.catalogs"
  
  # Check Trino version
  run_local_query "SELECT * FROM system.runtime.version"
else
  echo "Run these commands on Fly.io:"
  echo "============================"
  echo "# SSH into Trino"
  echo "fly ssh console -a trino-fly"
  echo
  echo "# Basic connectivity test"
  echo "trino --execute \"SELECT 1 AS test\""
  echo
  echo "# List catalogs"
  echo "trino --execute \"SHOW CATALOGS\""
  echo
  echo "# Iceberg catalog and schemas"
  echo "trino --execute \"SHOW SCHEMAS FROM iceberg\""
  echo
  echo "# System tables diagnostic info"
  echo "trino --execute \"SELECT * FROM system.runtime.nodes\""
  echo "trino --execute \"SELECT * FROM system.metadata.catalogs\""
  echo
  echo "# Check AWS environment variables"
  echo "env | grep -i AWS"
  echo
  echo "# Check for errors in logs"
  echo "fly logs -a trino-fly | grep -i error"
fi 