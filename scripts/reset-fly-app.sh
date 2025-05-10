#!/bin/bash
set -e

# The app name to reset
APP_NAME=$1

if [ -z "$APP_NAME" ]; then
  echo "Usage: $0 app-name"
  echo "Example: $0 superset-fly"
  exit 1
fi

echo "WARNING: This will destroy the Fly.io app $APP_NAME and recreate it"
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Operation cancelled"
  exit 1
fi

# Destroy the app
echo "Destroying app $APP_NAME..."
fly apps destroy $APP_NAME --yes

# Wait a moment for the backend to process
echo "Waiting for cleanup..."
sleep 5

# Move to the app directory
if [ -d "$APP_NAME" ]; then
  cd $APP_NAME
else
  echo "Error: Directory $APP_NAME not found"
  exit 1
fi

# Launch a new app with the same name and configuration
echo "Creating a new app $APP_NAME..."
fly launch --name $APP_NAME --no-deploy

echo "App $APP_NAME has been reset and is ready for deployment"
echo "Now you can run: cd $APP_NAME && fly deploy" 