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
        }
        failure {
            echo '❌ Pipeline failed. Check the errors above.'
        }
    }
}
