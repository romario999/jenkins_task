pipeline {
    agent any

    tools {
        nodejs 'node'
    }

    environment {
        DOCKER_IMAGE_TAG = "v1.0"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    BRANCH_NAME = env.BRANCH_NAME
                    IMAGE_NAME = "node${BRANCH_NAME}"
                    APP_PORT = (BRANCH_NAME == 'main') ? 3000 : 3001

                    echo "Branch: ${BRANCH_NAME}"
                    echo "Docker Image: ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    echo "App will run on port: ${APP_PORT}"
                }
            }
        }

        stage('Build') {
            steps {
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    sh "docker build -t ${IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Stop and Remove Previous Container') {
            steps {
                script {
                    echo "Stopping any previous container running on port ${APP_PORT}"
                    sh """
                    CONTAINER_ID=\$(docker ps -q --filter "publish=${APP_PORT}")
                    if [ -n "\$CONTAINER_ID" ]; then
                        echo "Found running container: \$CONTAINER_ID. Stopping..."
                        docker stop \$CONTAINER_ID
                        docker rm \$CONTAINER_ID
                    else
                        echo "No running container found."
                    fi
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying ${IMAGE_NAME}:${DOCKER_IMAGE_TAG} on port ${APP_PORT}"
                    sh "docker run -d --expose 3000 -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
    }
}
