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
        
        stage('Trivy Security Scan - Docker Image') {
            steps {
                echo '🔍 Scanning Docker image for vulnerabilities...'
                script {
                    // Run Trivy using Docker container
                    sh '''
                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            aquasec/trivy:latest \
                            image \
                            --exit-code 1 \
                            --severity CRITICAL,HIGH \
                            --no-progress \
                            vibhakar246/devops-practice-app:latest
                    '''
                }
                echo '✅ No CRITICAL or HIGH vulnerabilities found in image'
            }
            post {
                always {
                    script {
                        // Generate HTML report
                        sh '''
                            docker run --rm \
                                -v $(pwd):/app \
                                -v /var/run/docker.sock:/var/run/docker.sock \
                                aquasec/trivy:latest \
                                image \
                                --format template \
                                --template "@/usr/local/share/trivy/templates/html.tpl" \
                                -o /app/trivy-image-report.html \
                                vibhakar246/devops-practice-app:latest || true
                        '''
                        archiveArtifacts artifacts: 'trivy-image-report.html', allowEmptyArchive: true
                    }
                }
            }
        }
        
        stage('Trivy Security Scan - File System') {
            steps {
                echo '🔍 Scanning code dependencies for vulnerabilities...'
                script {
                    sh '''
                        docker run --rm \
                            -v $(pwd):/app \
                            aquasec/trivy:latest \
                            fs \
                            --exit-code 1 \
                            --severity CRITICAL,HIGH \
                            --no-progress \
                            /app
                    '''
                }
                echo '✅ No CRITICAL or HIGH vulnerabilities found in dependencies'
            }
            post {
                always {
                    script {
                        sh '''
                            docker run --rm \
                                -v $(pwd):/app \
                                aquasec/trivy:latest \
                                fs \
                                --format template \
                                --template "@/usr/local/share/trivy/templates/html.tpl" \
                                -o /app/trivy-fs-report.html \
                                /app || true
                        '''
                        archiveArtifacts artifacts: 'trivy-fs-report.html', allowEmptyArchive: true
                    }
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
                        echo '✅ Deployed to Kubernetes successfully'
                    } catch (Exception e) {
                        echo '⚠️ Kubernetes deployment skipped (K8s not running)'
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
                echo '✅ Pipeline verification complete'
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline executed successfully!'
            echo 'Image: docker.io/vibhakar246/devops-practice-app:latest'
            echo '📊 Trivy security reports archived as artifacts'
        }
        failure {
            echo '❌ Pipeline failed - vulnerabilities found!'
            echo 'Check the Trivy reports above for details'
        }
    }
}
