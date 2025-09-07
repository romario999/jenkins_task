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

        stage('Deploy Zero Downtime') {
            steps {
                script {
                    def TEMP_PORT = APP_PORT.toInteger() + 1000
                    echo "Deploying new container on temporary port ${TEMP_PORT}"

                    // Видаляємо попередній тимчасовий контейнер
                    sh """
                    docker stop ${IMAGE_NAME}_temp || true
                    docker rm ${IMAGE_NAME}_temp || true
                    docker run -d --name ${IMAGE_NAME}_temp -p ${TEMP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """

                    // Чекаємо, поки контейнер підніметься
                    sh """
                    ATTEMPTS=0
                    until [ "\$(docker inspect -f '{{.State.Running}}' ${IMAGE_NAME}_temp)" = "true" ] || [ \$ATTEMPTS -ge 10 ]; do
                        sleep 1
                        ATTEMPTS=\$((ATTEMPTS+1))
                    done
                    """

                    echo "New container is running on temp port"

                    // Швидко зупиняємо старий контейнер і переносимо новий на основний порт
                    sh """
                    OLD_CONTAINER=\$(docker ps -q --filter "publish=${APP_PORT}")
                    if [ -n "\$OLD_CONTAINER" ]; then
                        docker stop \$OLD_CONTAINER
                        docker rm \$OLD_CONTAINER
                    fi
                    docker stop ${IMAGE_NAME}_temp
                    docker rm ${IMAGE_NAME}_temp
                    docker run -d --name ${IMAGE_NAME}_${BRANCH_NAME} -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """

                    echo "Deployment completed with minimal downtime"
                }
            }
        }
    }
}
