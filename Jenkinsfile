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
                    def IMAGE_NAME = "node${env.BRANCH_NAME}"
                    echo "Building Docker image: ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    sh "docker build -t ${IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Starting deployment of ${IMAGE_NAME}:${DOCKER_IMAGE_TAG} with minimal downtime"

                    TEMP_PORT=$((APP_PORT + 1000))
                    TEMP_CONTAINER_NAME="${IMAGE_NAME}_temp"

                    sh """
                    echo "Running new container ${TEMP_CONTAINER_NAME} on port ${TEMP_PORT}"
                    docker run -d --name ${TEMP_CONTAINER_NAME} -p ${TEMP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """

                    OLD_CONTAINER_ID=$(sh(script: "docker ps -q --filter 'name=^${IMAGE_NAME}$'", returnStdout: true).trim())

                    if (OLD_CONTAINER_ID) {
                        echo "Stopping old container ${OLD_CONTAINER_ID}"
                        sh "docker stop ${OLD_CONTAINER_ID} && docker rm ${OLD_CONTAINER_ID}"
                    } else {
                        echo "No old container found"
                    }

                    sh """
                    echo "Restarting new container ${TEMP_CONTAINER_NAME} on main port ${APP_PORT}"
                    docker stop ${TEMP_CONTAINER_NAME} && docker rm ${TEMP_CONTAINER_NAME}
                    docker run -d --name ${IMAGE_NAME} -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """

                    echo "Deployment completed successfully!"
                }
            }
        }
    }
}
