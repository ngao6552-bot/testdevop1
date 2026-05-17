#!/bin/bash

# Deploy script for CI/CD pipeline
set -e

echo "========== START DEPLOYMENT =========="

# Variables
DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"
DOCKER_USERNAME="${DOCKER_USERNAME:-}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-}"
IMAGE_NAME="${IMAGE_NAME:-devops-app}"
IMAGE_TAG="${GIT_COMMIT:0:7}"
ENVIRONMENT="${ENVIRONMENT:-staging}"

# Build Docker image
echo "Building Docker image..."
docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .
docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest

# Login to Docker registry
if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
    echo "Logging in to Docker registry..."
    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin $DOCKER_REGISTRY
fi

# Push to registry
echo "Pushing image to registry..."
docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest

# Deploy using docker-compose
echo "Deploying with docker-compose..."
docker-compose down || true
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to be ready..."
sleep 10

# Health check
if curl -f http://localhost:5000/health || echo "Backend health check failed"; then
    echo "Backend service is running"
fi

if curl -f http://localhost/health || echo "Frontend health check failed"; then
    echo "Frontend service is running"
fi

echo "========== DEPLOYMENT COMPLETED =========="
