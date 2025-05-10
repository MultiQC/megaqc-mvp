# Build on top of the official Superset image (v4.1.0 as of May 2025)
# image maintained by the Superset PMC
FROM apache/superset     

USER root
# 1. Install DuckDB + SQLAlchemy dialect + httpfs extension for S3/HTTPS
# 2. Install Trino connector
RUN pip install --no-cache-dir \
    duckdb==1.2.2 \
    duckdb-engine \
    boto3 \
    trino

# 3. Copy Superset config
COPY superset_config.py /app/pythonpath/

# 4. Copy helper that creates the first admin and then starts Superset
COPY superset_init.sh /usr/bin/
RUN chmod +x /usr/bin/superset_init.sh

# Drop back to the non-root user that the base image defines
USER superset
ENTRYPOINT ["/usr/bin/superset_init.sh"]
