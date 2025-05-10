#!/bin/bash
# Debug script for Trino connection issues with Superset

# Check local connectivity
LOCAL_TRINO_CONTAINER=$(docker ps | grep trino-server | wc -l)
echo "Local Trino container status: $([ $LOCAL_TRINO_CONTAINER -gt 0 ] && echo "Running" || echo "Not running")"

if [ $LOCAL_TRINO_CONTAINER -gt 0 ]; then
  echo -e "\n=== Local Trino Environment Variables ==="
  docker exec trino-server env | grep -i AWS

  echo -e "\n=== Testing local Trino connection ==="
  docker exec trino-server trino --execute "SHOW CATALOGS"
  echo -e "\n=== Testing Iceberg catalog ==="
  docker exec trino-server trino --execute "SHOW SCHEMAS FROM iceberg"
fi

echo -e "\n=== Instructions for debugging Trino on Fly.io ==="
echo "1. SSH into the Trino container:"
echo "   fly ssh console -a trino-fly"
echo ""
echo "2. Check environment variables:"
echo "   env | grep -i AWS"
echo ""
echo "3. Test Trino connectivity:"
echo "   trino --execute \"SHOW CATALOGS\""
echo ""
echo "4. Test Iceberg schema:"
echo "   trino --execute \"SHOW SCHEMAS FROM iceberg\""
echo ""
echo "5. Check for AWS permission issues:"
echo "   trino --execute \"SELECT * FROM system.runtime.nodes\""
echo ""
echo "6. View Trino logs:"
echo "   fly logs -a trino-fly"
echo ""
echo "7. Test S3 access (if in the container):"
echo "   apt-get update && apt-get install -y curl"
echo "   curl -I https://vlad-megaqc.s3.eu-central-1.amazonaws.com/"
echo ""
echo "8. From Superset, check Trino connection:"
echo "   fly ssh console -a superset-fly"
echo "   python -c \"import trino; conn = trino.dbapi.connect(host='trino-fly.internal', port=8080, user='admin', catalog='iceberg'); cursor = conn.cursor(); cursor.execute('SHOW CATALOGS'); print(cursor.fetchall())\"" 