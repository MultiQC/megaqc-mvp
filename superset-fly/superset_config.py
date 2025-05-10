import os

# Use a strong complex alphanumeric string for SECRET_KEY
SECRET_KEY = 'UDECcLZiO3LncPs8gs6RWUZxh7avWJovIStgJnfkbyGgQFmCsfjBAZRh'

# Configure other necessary settings
SQLALCHEMY_DATABASE_URI = os.environ.get('SUPERSET_DB_URI', 'sqlite:////app/superset/superset.db')
