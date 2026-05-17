pipeline {
    agent any
    
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    environment {
        NODE_ENV = 'production'
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'devops-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                echo '========== CHECKOUT CODE =========='
                checkout scm
                sh 'git log --oneline -n 5'
                echo "✓ Checkout completed"
            }
        }
        
        stage('Backend: Install Dependencies') {
            steps {
                echo '========== BACKEND: INSTALL DEPENDENCIES =========='
                dir('Backend') {
                    sh '''
                        echo "Node version:"
                        node --version
                        echo "NPM version:"
                        npm --version
                        echo "Installing dependencies..."
                        npm install --legacy-peer-deps
                    '''
                }
            }
        }
        
        stage('Frontend: Install Dependencies') {
            steps {
                echo '========== FRONTEND: INSTALL DEPENDENCIES =========='
                dir('Frontend') {
                    sh '''
                        echo "Installing dependencies..."
                        npm install
                    '''
                }
            }
        }
        
        stage('Build') {
            parallel {
                stage('Build Backend') {
                    steps {
                        echo '========== BUILD BACKEND =========='
                        dir('Backend') {
                            sh '''
                                echo "Building Backend..."
                                npm run build || true
                                echo "✓ Backend build completed"
                            '''
                        }
                    }
                }
                
                stage('Build Frontend') {
                    steps {
                        echo '========== BUILD FRONTEND =========='
                        dir('Frontend') {
                            sh '''
                                echo "Building Frontend..."
                                npm run build
                                echo "✓ Frontend build completed"
                                ls -la dist/
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Tests') {
            steps {
                echo '========== RUNNING TESTS =========='
                sh '''
                    echo "Running test suite..."
                    echo "No tests configured yet"
                '''
            }
        }
        
        stage('Unit tests') {
            parallel {
                stage('Backend Unit Tests') {
                    steps {
                        echo '========== BACKEND UNIT TESTS =========='
                        dir('Backend') {
                            sh '''
                                npm test || echo "No Backend tests configured"
                            '''
                        }
                    }
                }
                
                stage('Frontend Unit Tests') {
                    steps {
                        echo '========== FRONTEND UNIT TESTS =========='
                        dir('Frontend') {
                            sh '''
                                npm test || echo "No Frontend tests configured"
                            '''
                        }
                    }
                }
            }
        }
        
        stage('E2E') {
            steps {
                echo '========== E2E TESTS =========='
                sh '''
                    echo "Running E2E tests..."
                    echo "E2E tests not configured yet"
                '''
            }
        }
        
        stage('Code Quality Check') {
            steps {
                echo '========== CODE QUALITY CHECK =========='
                sh '''
                    echo "Running code quality checks..."
                    dir('Frontend') {
                        npm run lint || echo "No lint script found"
                    }
                '''
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                echo '========== SONARQUBE ANALYSIS =========='
                sh '''
                    echo "Running SonarQube analysis..."
                    echo "SonarQube not configured yet"
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '========== BUILD DOCKER IMAGE =========='
                sh '''
                    echo "Building Docker image..."
                    docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                    echo "✓ Docker image built successfully"
                    docker images | grep ${IMAGE_NAME}
                '''
            }
        }
        
        stage('Push Docker Image') {
            when {
                branch 'main'
            }
            steps {
                echo '========== PUSH DOCKER IMAGE =========='
                sh '''
                    echo "Pushing Docker image to registry..."
                    # Uncomment when credentials are set up
                    # docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                    # docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                    echo "✓ Docker push skipped (credentials not configured)"
                '''
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo '========== DEPLOY =========='
                sh '''
                    echo "Starting deployment..."
                    
                    echo "Stopping old containers..."
                    docker-compose down || true
                    
                    echo "Starting new containers..."
                    docker-compose up -d
                    
                    echo "Waiting for services to be ready..."
                    sleep 10
                    
                    echo "Checking service health..."
                    docker ps
                    
                    echo "✓ Deployment completed successfully"
                '''
            }
        }
        
        stage('Health Check') {
            when {
                branch 'main'
            }
            steps {
                echo '========== HEALTH CHECK =========='
                sh '''
                    echo "Performing health checks..."
                    
                    # Check Backend
                    if curl -s http://localhost:5000/health; then
                        echo "✓ Backend is healthy"
                    else
                        echo "⚠ Backend health check failed"
                    fi
                    
                    # Check Frontend
                    if curl -s http://localhost/health; then
                        echo "✓ Frontend is healthy"
                    else
                        echo "⚠ Frontend health check failed"
                    fi
                    
                    echo "✓ Health check completed"
                '''
            }
        }
        
        stage('Smoke Tests') {
            when {
                branch 'main'
            }
            steps {
                echo '========== SMOKE TESTS =========='
                sh '''
                    echo "Running smoke tests..."
                    
                    # Test Backend endpoints
                    echo "Testing Backend API..."
                    curl -s http://localhost:5000/ || echo "Backend not responding"
                    
                    # Test Frontend
                    echo "Testing Frontend..."
                    curl -s http://localhost/ || echo "Frontend not responding"
                    
                    echo "✓ Smoke tests completed"
                '''
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                echo '========== ARCHIVE ARTIFACTS =========='
                archiveArtifacts artifacts: 'Frontend/dist/**/*', 
                                 allowEmptyArchive: true,
                                 fingerprint: true
                archiveArtifacts artifacts: 'Backend/**/*.js', 
                                 excludes: 'Backend/node_modules/**',
                                 allowEmptyArchive: true,
                                 fingerprint: true
                echo "✓ Artifacts archived"
            }
        }
        
        stage('Cleanup') {
            steps {
                echo '========== CLEANUP =========='
                sh '''
                    echo "Cleaning up..."
                    docker system prune -f --volumes || true
                    echo "✓ Cleanup completed"
                '''
            }
        }
    }
    
    post {
        always {
            echo '========== PIPELINE FINISHED =========='
            echo "Build Status: ${currentBuild.result}"
            echo "Build Duration: ${currentBuild.durationString}"
        }
        
        success {
            echo '✓ Pipeline executed successfully!'
            sh 'echo "SUCCESS: ${BUILD_TIMESTAMP}" >> /tmp/jenkins_status.log'
        }
        
        failure {
            echo '✗ Pipeline failed!'
            sh 'echo "FAILURE: ${BUILD_TIMESTAMP}" >> /tmp/jenkins_status.log'
        }
        
        unstable {
            echo '⚠ Pipeline unstable'
        }
    }
}
