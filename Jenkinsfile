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
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
                echo '✅ Deployed to Kubernetes'
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline successful!'
            echo 'Image: docker.io/vibhakar246/devops-practice-app:latest'
        }
        failure {
            echo '❌ Pipeline failed'
        }
    }
}
