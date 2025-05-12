#!/bin/bash
set -e

# Parse command line arguments
RELAUNCH=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--relaunch)
      RELAUNCH=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [-f|--force] [-r|--relaunch]"
      echo "  -f, --force     Force redeployment even if apps are already running"
      echo "  -r, --relaunch  Destroy and recreate the apps (complete relaunch)"
      exit 1
      ;;
  esac
done

# Check if fly is installed
if ! command -v fly &> /dev/null; then
    echo "Fly.io CLI not found. Please install it first:"
    echo "curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if logged in
echo "Checking Fly.io login status..."
fly auth whoami || fly auth login

# Function to check if an app is running
check_app_status() {
  app_name=$1
  echo "Checking if $app_name is running..."
  if fly status -a $app_name 2>/dev/null | grep -q "running"; then
    return 0  # App is running
  else
    return 1  # App is not running
  fi
}

# Function to check if an app exists
check_app_exists() {
  app_name=$1
  if fly apps list | grep -q "\s$app_name\s"; then
    return 0  # App exists
  else
    return 1  # App doesn't exist
  fi
}

# Function to destroy an app
destroy_app() {
  app_name=$1
  echo "Destroying $app_name..."
  fly apps destroy $app_name --yes
}

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

# Deploy Trino service
if $RELAUNCH; then
    if check_app_exists "megaqc-trino"; then
        destroy_app "megaqc-trino"
    fi
    echo "Launching Trino service..."
    cd megaqc-trino
    fly deploy
elif ! check_app_status "megaqc-trino"; then
    echo "Deploying Trino service..."
    cd megaqc-trino
    fly deploy
else
    echo "Trino service is already running. Use -f/--force to redeploy or -r/--relaunch to destroy and recreate."
fi

# Return to root directory
cd "$(dirname "$0")"

# Deploy Superset service
if $RELAUNCH; then
    if check_app_exists "megaqc-superset"; then
        destroy_app "megaqc-superset"
    fi
    echo "Launching Superset service..."
    cd megaqc-superset
    fly deploy
elif ! check_app_status "megaqc-superset"; then
    echo "Deploying Superset service..."
    cd megaqc-superset
    fly deploy
else
    echo "Superset service is already running. Use -f/--force to redeploy or -r/--relaunch to destroy and recreate."
fi

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