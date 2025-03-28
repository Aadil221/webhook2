pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE_NAME = "aadilnn/python-app"
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
                        docker logs test-python
                    """
                }
            }
            post {
                always {
                    script {
                        sh '''
                            docker stop test-python || true
                            docker rm test-python || true
                        '''
                    }
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        sh """
                            echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin
                            docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                            docker push ${DOCKER_IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                sh '''
                    docker logout || true
                    docker system prune -f || true
                '''
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
