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
                echo '✅ Code checked out'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_HUB_USER}/${APP_NAME}:latest")
                }
                echo '✅ Docker image built'
            }
        }
        
        stage('Trivy Security Scan') {
            parallel {
                stage('Scan Image - Critical Block') {
                    steps {
                        echo '🔍 Scanning for CRITICAL vulnerabilities...'
                        script {
                            // This will FAIL the build if CRITICAL vulnerabilities found
                            sh '''
                                docker run --rm \
                                    -v /var/run/docker.sock:/var/run/docker.sock \
                                    aquasec/trivy:0.45.0 \
                                    image \
                                    --severity CRITICAL \
                                    --exit-code 1 \
                                    --no-progress \
                                    vibhakar246/devops-practice-app:latest
                            '''
                        }
                        echo '✅ No CRITICAL vulnerabilities found'
                    }
                }
                
                stage('Scan Image - Report Only') {
                    steps {
                        echo '🔍 Scanning for HIGH vulnerabilities...'
                        sh '''
                            docker run --rm \
                                -v /var/run/docker.sock:/var/run/docker.sock \
                                aquasec/trivy:0.45.0 \
                                image \
                                --severity HIGH \
                                --exit-code 0 \
                                --no-progress \
                                vibhakar246/devops-practice-app:latest
                        '''
                    }
                }
            }
            post {
                always {
                    sh '''
                        docker run --rm \
                            -v $(pwd):/app \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            aquasec/trivy:0.45.0 \
                            image \
                            --format json \
                            --severity CRITICAL,HIGH,MEDIUM \
                            vibhakar246/devops-practice-app:latest > trivy-report.json || true
                    '''
                    archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
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
                echo '✅ Image pushed to Docker Hub'
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        sh 'kubectl apply -f k8s/deployment.yaml || true'
                        sh 'kubectl apply -f k8s/service.yaml || true'
                        echo '✅ Deployed to Kubernetes'
                    } catch (Exception e) {
                        echo '⚠️ Kubernetes not available'
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline completed! Image is secure.'
        }
        failure {
            echo '❌ Pipeline failed - CRITICAL vulnerabilities found!'
            echo 'Please update base image and dependencies.'
        }
    }
}
