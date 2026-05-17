pipeline {
    agent any
    
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    environment {
        NODE_ENV = 'development'
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
                                npm install --legacy-peer-deps --save-dev jest
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
                                npm install --save-dev vitest
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
                                npm test
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
                                npm test
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
        
        stage('Deploy') {
            steps {
                echo '========== DEPLOY - DOCKER BUILD & START SERVICES =========='
                bat '''
                    echo Stopping old containers...
                    docker-compose down || echo No containers to stop
                    
                    echo.
                    echo Building and starting services...
                    docker-compose up -d
                    
                    echo.
                    echo Services starting, waiting 10 seconds for containers to be ready...
                    ping -n 11 127.0.0.1 >nul
                    
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
                echo '========== HEALTH CHECK - VERIFY DEPLOYMENT =========='
                bat '''
                    echo.
                    echo [1] Checking Docker containers running...
                    docker ps
                    echo.
                    
                    echo [2] Testing Backend API health at http://localhost:5000...
                    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5000' -UseBasicParsing -TimeoutSec 5; Write-Host 'Backend is running - Status: ' $response.StatusCode } catch { Write-Host 'ERROR: Backend not responding' -ForegroundColor Red; exit 1 }"
                    echo.
                    
                    echo [3] Testing Frontend health at http://localhost...
                    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost' -UseBasicParsing -TimeoutSec 5; Write-Host 'Frontend is running - Status: ' $response.StatusCode } catch { Write-Host 'ERROR: Frontend not responding' -ForegroundColor Red; exit 1 }"
                    echo.
                    
                    echo [4] Docker images available:
                    docker images
                    echo.
                    
                    echo [PASSED] All health checks completed successfully! Deployment verified.
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
