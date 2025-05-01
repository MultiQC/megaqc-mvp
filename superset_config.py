import os
from typing import Dict, Any
from superset.extensions import security_manager


def duckdb_r2_engine_params(_: "Database") -> Dict[str, Any]:
    """Inject httpfs + R2 credentials on every DuckDB connection."""
    return {
        "preload_extensions": ["httpfs", "iceberg"],  # load both, costs <1 MB
        "config": {
            "s3_access_key_id": os.getenv("R2_ACCESS_KEY_ID"),
            "s3_secret_access_key": os.getenv("R2_SECRET_ACCESS_KEY"),
            "s3_endpoint": os.getenv("R2_ENDPOINT"),
            "s3_region": "auto",  # R2 ignores region but DuckDB needs a value
            "s3_url_style": "path",
        },
    }


# Map only the DuckDB driver
SECURITY_DATABASE_ENGINE_PARAMS = {
    "duckdb": duckdb_r2_engine_params,  # key = dialect name
}
