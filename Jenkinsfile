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
                    def BRANCH_NAME = env.BRANCH_NAME
                    def IMAGE_NAME = "node${BRANCH_NAME}"
                    def APP_PORT = (BRANCH_NAME == 'main') ? 3000 : 3001

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

        stage('Deploy') {
            steps {
                script {
                    def TEMP_PORT = APP_PORT + 1000
                    echo "Deploying new container on temp port ${TEMP_PORT}"

                    sh "docker run -d --expose 3000 -p ${TEMP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

                    echo "Switching ports..."
                    sh """
                    OLD_CONTAINER=$(docker ps -q --filter ancestor=${IMAGE_NAME}:${DOCKER_IMAGE_TAG})
                    if [ -n "$OLD_CONTAINER" ]; then
                        docker stop $OLD_CONTAINER
                        docker rm $OLD_CONTAINER
                    fi

                    docker run -d --expose 3000 -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}

                    TEMP_CONTAINER=$(docker ps -q --filter "publish=${TEMP_PORT}")
                    if [ -n "$TEMP_CONTAINER" ]; then
                        docker stop $TEMP_CONTAINER
                        docker rm $TEMP_CONTAINER
                    fi
                    """
                }
            }
        }
    }
}

