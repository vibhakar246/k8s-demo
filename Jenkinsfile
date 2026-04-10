cd ~/devops-practice-project

# Update Jenkinsfile for ECR
cat > Jenkinsfile << 'EOF'
pipeline {
    agent any
    
    environment {
        // AWS ECR Configuration - UPDATE THESE VALUES
        AWS_ACCOUNT_ID = '123456789012'  // Replace with your AWS account ID
        AWS_REGION = 'us-east-1'          // Replace with your ECR region
        ECR_REPO_NAME = 'devops-practice-app'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        APP_NAME = 'devops-practice-app'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                echo '📦 Checking out code from GitHub...'
                checkout scm
                echo '✅ Code checked out successfully'
                sh 'ls -la'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    dockerImage = docker.build("${ECR_REGISTRY}/${ECR_REPO_NAME}:latest")
                }
                echo '✅ Docker image built successfully'
            }
        }
        
        stage('Push to Amazon ECR') {
            steps {
                echo '📤 Pushing image to Amazon ECR...'
                script {
                    // Using ecr plugin for authentication [citation:1]
                    docker.withRegistry("https://${ECR_REGISTRY}", "ecr:${AWS_REGION}:aws-ecr-credentials") {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
                echo '✅ Image pushed to ECR successfully'
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Deploying to Kubernetes...'
                script {
                    try {
                        // Update deployment with ECR image
                        sh """
                            sed -i 's|image:.*|image: ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest|g' k8s/deployment.yaml
                            cat k8s/deployment.yaml
                        """
                        sh 'kubectl apply -f k8s/deployment.yaml'
                        sh 'kubectl apply -f k8s/service.yaml'
                        sh 'kubectl rollout status deployment/devops-app-deployment --timeout=60s'
                        echo '✅ Deployment successful'
                    } catch (Exception e) {
                        echo '⚠️ Kubernetes may not be running. Continuing...'
                        echo "Error: ${e.message}"
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '🔍 Checking deployment status...'
                script {
                    try {
                        sh 'kubectl get pods'
                        sh 'kubectl get services'
                        echo '✅ Verification complete'
                    } catch (Exception e) {
                        echo '⚠️ Unable to verify Kubernetes resources'
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline executed successfully!'
            echo 'Image pushed to: ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest'
            echo 'Application should be available at: http://localhost:30080'
        }
        failure {
            echo '❌ Pipeline failed. Check the errors above.'
            echo 'Common fixes:'
            echo '1. Ensure AWS credentials are correct'
            echo '2. Verify ECR repository exists'
            echo '3. Check IAM permissions for ECR push access'
        }
    }
}
EOF

# Commit and push
git add Jenkinsfile
git commit -m "Switch from Docker Hub to Amazon ECR"
git push origin main
