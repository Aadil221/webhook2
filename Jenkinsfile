pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE_NAME = "your-dockerhub-username/python-app"
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
                sh """
                    docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .
                    docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest
                """
            }
        }
        
        stage('Test') {
            steps {
                sh """
                    docker run -d --name test-python -p 8082:5000 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    sleep 10
                    curl http://localhost:8082 || exit 1
                    docker logs test-python
                """
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
                sh """
                    echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                    docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    docker push ${DOCKER_IMAGE_NAME}:latest
                """
            }
        }
    }
    
    post {
        always {
            sh """
                docker logout
                docker system prune -f
            """
        }
        success {
            echo 'Successfully built and pushed image'
        }
        failure {
            echo 'Failed to build and push image'
        }
    }
}
