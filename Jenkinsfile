pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE_NAME = "aadillnn/python-app"
        DOCKER_IMAGE_TAG = "v${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Image') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .
                        docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    sh """
                        docker run -d --name test-python -p 8082:5000 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                        sleep 10
                        curl http://localhost:8082 || exit 1
                    """
                }
            }
            post {
                always {
                    sh 'docker stop test-python || true'
                    sh 'docker rm test-python || true'
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', 
                                                passwordVariable: 'DOCKERHUB_PASSWORD', 
                                                usernameVariable: 'DOCKERHUB_USERNAME')]) {
                    sh """
                        echo \${DOCKERHUB_PASSWORD} | docker login -u \${DOCKERHUB_USERNAME} --password-stdin
                        docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                        docker push ${DOCKER_IMAGE_NAME}:latest
                    """
                }
            }
        }
    }
    
    post {
        always {
            node('any') {
                sh 'docker logout || true'
                sh 'docker system prune -f || true'
            }
        }
        success {
            echo 'Successfully built and pushed image'
        }
        failure {
            echo 'Failed to build and push image'
        }
    }
}
