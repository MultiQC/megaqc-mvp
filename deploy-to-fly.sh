#!/bin/bash
set -e

# Check if fly is installed
if ! command -v fly &> /dev/null; then
    echo "Fly.io CLI not found. Please install it first:"
    echo "curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if logged in
echo "Checking Fly.io login status..."
fly auth whoami || fly auth login

# The apps will be automatically connected via the private network
# as long as they're in the same organization
echo "Note: Fly.io apps in the same organization can communicate via private networking automatically"
echo "The hostname will be: megaqc-trino.internal:8080"

# Set AWS secrets
echo "Setting secrets for Trino..."
if [ -f ".env" ]; then
    fly secrets import < .env -a megaqc-trino  # needs AWS secrets
    fly secrets import < .env -a megaqc-superset  # needs PASSWORD
else
    echo "WARNING: .env not found. You'll need to set AWS credentials and Superset PASSWORD manually."
    echo "Use: fly secrets set AWS_ACCESS_KEY_ID=your_key AWS_SECRET_ACCESS_KEY=your_secret -a megaqc-trino"
    echo "Use: fly secrets set PASSWORD=your_password -a megaqc-superset"
fi

# Deploy Trino service first
echo "Deploying Trino service..."
cd trino-fly
fly deploy

# Deploy Superset service with more detailed output
echo "Deploying Superset service..."
cd ../superset-fly
fly deploy

echo "Deployment completed!"
echo "Your Superset instance is available at: https://megaqc-superset.fly.dev"
echo "Your Trino instance is available at: https://megaqc-trino.fly.dev"
echo ""
echo "Trino and Superset should be able to communicate via Fly.io's internal network."
echo "Superset should connect to Trino at: megaqc-trino.internal:8080"
echo ""
echo "To verify connectivity, you can run:"
echo "fly ssh console -a megaqc-superset"
echo "ping megaqc-trino.internal" 