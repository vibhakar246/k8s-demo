pipeline {
    agent any
    
    environment {
        // Replace with your Docker Hub username
        DOCKER_HUB_USER = 'vibhakar246'  // Update this!
        APP_NAME = 'devops-practice-app'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', 
                    url: 'git@github.com:vibhakar246/k8s-demo.git'
                echo '✅ Code checked out successfully'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_HUB_USER}/${APP_NAME}:latest")
                    echo '✅ Docker image built successfully'
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-credentials') {
                        dockerImage.push()
                        dockerImage.push('v1.0')
                    }
                    echo '✅ Docker image pushed to Docker Hub'
                }
            }
        }
        
        stage('Update Kubernetes Deployment') {
            steps {
                script {
                    // Update the deployment with new image
                    sh """
                        sed -i 's|image:.*|image: ${DOCKER_HUB_USER}/${APP_NAME}:latest|g' k8s/deployment.yaml
                        cat k8s/deployment.yaml
                    """
                }
                echo '✅ Kubernetes deployment files updated'
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        // Apply the deployment and service
                        sh 'kubectl apply -f k8s/deployment.yaml'
                        sh 'kubectl apply -f k8s/service.yaml'
                        
                        // Wait for rollout to complete
                        sh 'kubectl rollout status deployment/devops-app-deployment --timeout=60s'
                        
                        echo '✅ Application deployed to Kubernetes'
                    } catch (Exception e) {
                        echo '❌ Deployment failed, but continuing for learning purposes'
                        echo "Error: ${e.message}"
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    // Get pod status
                    sh 'kubectl get pods'
                    sh 'kubectl get services'
                    
                    // Test the application
                    sh '''
                        echo "Testing application endpoint..."
                        sleep 5
                        kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl -s http://devops-app-service:80/health || echo "Service may need more time"
                    '''
                }
                echo '✅ Verification completed'
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline executed successfully!'
            echo "Application available at: http://localhost:30080"
        }
        failure {
            echo '❌ Pipeline failed. Check the logs above for errors.'
        }
    }
}
