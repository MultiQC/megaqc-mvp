#!/bin/bash

# Run this locally to check AWS credentials in your Trino container
echo "Checking AWS credentials in local Trino container..."
docker exec trino-server env | grep -i AWS

echo ""
echo "To check on Fly.io, run the following:"
echo "fly ssh console -a trino-fly"
echo "env | grep -i AWS" 