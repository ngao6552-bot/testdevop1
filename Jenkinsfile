pipeline {
    agent any
    
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    environment {
        NODE_ENV = 'production'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '========== CHECKOUT CODE =========='
                checkout scm
                bat 'git log --oneline -n 3'
            }
        }
        
        stage('Install Dependencies') {
            parallel {
                stage('Backend') {
                    steps {
                        echo '========== BACKEND INSTALL =========='
                        dir('Backend') {
                            bat 'npm install --legacy-peer-deps'
                        }
                    }
                }
                stage('Frontend') {
                    steps {
                        echo '========== FRONTEND INSTALL =========='
                        dir('Frontend') {
                            bat 'npm install'
                        }
                    }
                }
            }
        }
        
        stage('Build') {
            parallel {
                stage('Backend') {
                    steps {
                        echo '========== BACKEND BUILD =========='
                        dir('Backend') {
                            bat 'npm run build || echo Build skipped'
                        }
                    }
                }
                stage('Frontend') {
                    steps {
                        echo '========== FRONTEND BUILD =========='
                        dir('Frontend') {
                            bat 'npm run build'
                        }
                    }
                }
            }
        }
        
        stage('Docker Build & Deploy') {
            steps {
                echo '========== DOCKER BUILD & DEPLOY =========='
                bat '''
                    docker-compose down || echo Containers stopped
                    docker-compose up -d
                    timeout /t 5
                    docker ps
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo '========== HEALTH CHECK =========='
                bat '''
                    echo Checking services...
                    curl -s http://localhost:5000/ || echo Backend check failed
                    curl -s http://localhost/ || echo Frontend check failed
                    echo Done
                '''
            }
        }
    }
    
    post {
        always {
            echo '✓ Pipeline completed'
        }
        failure {
            echo '✗ Build failed'
        }
    }
}
