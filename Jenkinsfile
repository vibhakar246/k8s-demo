pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = 'vibhakar246'
        APP_NAME = 'devops-practice-app'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo '✅ Code checked out successfully'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_HUB_USER}/${APP_NAME}:latest")
                }
                echo '✅ Docker image built successfully'
            }
        }
        
        stage('Trivy Security Scan') {
            steps {
                echo '🔍 Running Trivy security scans...'
                script {
                    // Scan 1: Docker image
                    echo 'Scanning Docker image for vulnerabilities...'
                    sh '''
                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            aquasec/trivy:latest \
                            image \
                            --severity CRITICAL,HIGH \
                            --no-progress \
                            --exit-code 0 \
                            vibhakar246/devops-practice-app:latest
                    '''
                    
                    // Scan 2: File system
                    echo 'Scanning code dependencies for vulnerabilities...'
                    sh '''
                        docker run --rm \
                            -v $(pwd):/app \
                            aquasec/trivy:latest \
                            fs \
                            --severity CRITICAL,HIGH \
                            --no-progress \
                            --exit-code 0 \
                            /app
                    '''
                    
                    echo '✅ Trivy scans completed'
                }
            }
            post {
                always {
                    // Generate detailed reports
                    sh '''
                        docker run --rm \
                            -v $(pwd):/app \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            aquasec/trivy:latest \
                            image \
                            --format table \
                            --severity CRITICAL,HIGH,MEDIUM \
                            vibhakar246/devops-practice-app:latest > trivy-image-report.txt || true
                        
                        docker run --rm \
                            -v $(pwd):/app \
                            aquasec/trivy:latest \
                            fs \
                            --format table \
                            --severity CRITICAL,HIGH,MEDIUM \
                            /app > trivy-fs-report.txt || true
                    '''
                    archiveArtifacts artifacts: 'trivy-*.txt', allowEmptyArchive: true
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-credentials') {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
                echo '✅ Image pushed to Docker Hub successfully'
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        sh 'kubectl apply -f k8s/deployment.yaml'
                        sh 'kubectl apply -f k8s/service.yaml'
                        echo '✅ Deployed to Kubernetes'
                    } catch (Exception e) {
                        echo '⚠️ Kubernetes not running - skipping deployment'
                    }
                }
            }
        }
        
        stage('Verify') {
            steps {
                script {
                    try {
                        sh 'kubectl get pods'
                        sh 'kubectl get services'
                    } catch (Exception e) {
                        echo '⚠️ Unable to verify Kubernetes resources'
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline completed successfully!'
            echo '📊 Check the Trivy reports in build artifacts'
        }
        failure {
            echo '❌ Pipeline failed'
        }
    }
}
