# Build on top of the official Superset image (v4.1.0 as of May 2025)
# image maintained by the Superset PMC
FROM apache/superset:latest     

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    libpq-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \
    boto3 \
    trino \
    psycopg2-binary \
    mysqlclient \
    sqlalchemy-trino

# Copy Superset config
COPY superset_config.py /app/pythonpath/

# Copy helper that creates the first admin and then starts Superset
COPY superset_init.sh /usr/bin/
RUN chmod +x /usr/bin/superset_init.sh

# Set working directory
WORKDIR /app

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/healthcheck || exit 1

# Drop back to the non-root user that the base image defines
USER superset

# Default command
ENTRYPOINT ["/usr/bin/superset_init.sh"]
