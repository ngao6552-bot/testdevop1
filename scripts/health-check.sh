#!/bin/bash

# Health check script for monitoring
echo "Checking Backend health..."
curl -s http://localhost:5000/health || echo "Backend is DOWN"

echo "Checking Frontend health..."
curl -s http://localhost/health || echo "Frontend is DOWN"

echo "Checking Docker containers..."
docker ps

echo "Checking disk space..."
df -h

echo "Health check completed at $(date)"
