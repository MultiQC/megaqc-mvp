#!/bin/bash
set -e

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Load environment variables from .env
source .env

# Ensure the required AWS variables are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_REGION" ]; then
    echo "Error: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, or AWS_REGION not set in .env file"
    exit 1
fi

# Set the secrets in Fly.io
echo "Setting AWS secrets in Fly.io..."
fly secrets set \
    AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    AWS_REGION="$AWS_REGION" \
    --app megaqc-trino

# Deploy the application
echo "Deploying Trino to Fly.io..."
cd trino-fly
fly deploy

echo "Deployment complete!"