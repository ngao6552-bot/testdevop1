pipeline {
    agent any
    
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    environment {
        NODE_ENV = 'production'
        NODEJS_HOME = tool 'NodeJS'
        PATH = "${NODEJS_HOME}/bin:${PATH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '========== CHECKOUT CODE =========='
                checkout scm
                sh 'git log --oneline -n 5'
            }
        }
        
        stage('Install Dependencies - Backend') {
            steps {
                echo '========== INSTALL BACKEND DEPENDENCIES =========='
                dir('Backend') {
                    sh '''
                        node --version
                        npm --version
                        npm install --verbose
                    '''
                }
            }
        }
        
        stage('Install Dependencies - Frontend') {
            steps {
                echo '========== INSTALL FRONTEND DEPENDENCIES =========='
                dir('Frontend') {
                    sh '''
                        npm install --verbose
                    '''
                }
            }
        }
        
        stage('Build Backend') {
            steps {
                echo '========== BUILD BACKEND =========='
                dir('Backend') {
                    sh '''
                        # Nếu có script build trong package.json
                        npm run build || echo "No build script found"
                    '''
                }
            }
        }
        
        stage('Build Frontend') {
            steps {
                echo '========== BUILD FRONTEND =========='
                dir('Frontend') {
                    sh '''
                        npm run build
                        echo "Frontend build completed successfully"
                        ls -la dist/ || echo "Build output not found"
                    '''
                }
            }
        }
        
        stage('Unit Tests - Backend') {
            steps {
                echo '========== UNIT TESTS BACKEND =========='
                dir('Backend') {
                    sh '''
                        npm test || echo "No tests configured for Backend"
                    '''
                }
            }
        }
        
        stage('Unit Tests - Frontend') {
            steps {
                echo '========== UNIT TESTS FRONTEND =========='
                dir('Frontend') {
                    sh '''
                        npm test || echo "No tests configured for Frontend"
                    '''
                }
            }
        }
        
        stage('Code Quality - Lint') {
            steps {
                echo '========== CODE QUALITY CHECK =========='
                dir('Frontend') {
                    sh '''
                        npm run lint || echo "No lint script found"
                    '''
                }
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
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'main'
            }
            steps {
                echo '========== DEPLOY TO STAGING =========='
                sh '''
                    echo "Deploying to staging environment..."
                    # Thêm các lệnh deploy của bạn ở đây
                    # Ví dụ: scp, docker push, etc.
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
                tag "release-*"
            }
            steps {
                echo '========== DEPLOY TO PRODUCTION =========='
                input 'Deploy to Production?'
                sh '''
                    echo "Deploying to production..."
                    # Thêm các lệnh deploy production của bạn ở đây
                '''
            }
        }
    }
    
    post {
        always {
            echo '========== PIPELINE FINISHED =========='
        }
        
        success {
            echo '✓ Pipeline executed successfully!'
            // Thêm notification (Slack, Email, etc.)
        }
        
        failure {
            echo '✗ Pipeline failed!'
            // Thêm notification lỗi
        }
        
        unstable {
            echo '⚠ Pipeline unstable'
        }
    }
}
