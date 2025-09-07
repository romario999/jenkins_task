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
            steps { sh 'npm install' }
        }

        stage('Test') {
            steps { sh 'npm test' }
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
                    // 1. Знаходимо старий контейнер за образом
                    def OLD_CONTAINER = sh(
                        script: "docker ps -q --filter ancestor=${IMAGE_NAME}:${DOCKER_IMAGE_TAG}",
                        returnStdout: true
                    ).trim()

                    if (OLD_CONTAINER) {
                        echo "Stopping old container ${OLD_CONTAINER}"
                        sh "docker stop ${OLD_CONTAINER} && docker rm ${OLD_CONTAINER}"
                    } else {
                        echo "No old container found"
                    }

                    // 2. Запускаємо новий контейнер на основному порту
                    echo "Starting new container on port ${APP_PORT}"
                    sh "docker run -d -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
    }
}
