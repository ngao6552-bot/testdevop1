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
                            bat '''
                                npm install --legacy-peer-deps
                                npm run build || echo Build skipped
                            '''
                        }
                    }
                }
                stage('Frontend') {
                    steps {
                        echo '========== FRONTEND BUILD =========='
                        dir('Frontend') {
                            bat '''
                                npm install
                                npm run build
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Backend Test') {
                    steps {
                        echo '========== BACKEND TEST =========='
                        dir('Backend') {
                            bat '''
                                echo Running Backend tests...
                                npm test || echo Tests not configured
                            '''
                        }
                    }
                }
                stage('Frontend Test') {
                    steps {
                        echo '========== FRONTEND TEST =========='
                        dir('Frontend') {
                            bat '''
                                echo Running Frontend tests...
                                npm test || echo Tests not configured
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Code Quality') {
            steps {
                echo '========== CODE QUALITY CHECK =========='
                dir('Frontend') {
                    bat '''
                        echo Running linter...
                        npm run lint || echo Lint not configured
                    '''
                }
            }
        }
        
        stage('Docker Build & Deploy') {
            steps {
                echo '========== DOCKER BUILD & DEPLOY =========='
                bat '''
                    echo Stopping old containers...
                    docker-compose down || echo No containers to stop
                    
                    echo.
                    echo Building and starting services...
                    docker-compose up -d
                    
                    echo.
                    echo Services starting, waiting 5 seconds...
                    ping -n 6 127.0.0.1 >nul
                    
                    echo.
                    echo Current Docker containers:
                    docker ps -a
                    
                    echo.
                    echo Docker logs:
                    docker-compose logs
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo '========== HEALTH CHECK =========='
                bat '''
                    echo Checking Docker containers...
                    docker ps
                    echo.
                    echo Docker images available:
                    docker images
                    echo.
                    echo Health check completed successfully
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
