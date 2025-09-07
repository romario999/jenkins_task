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

        stage('Deploy with Minimal Downtime') {
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

                    // Чекаємо, поки Docker підтвердить, що контейнер запущений
                    sh """
                    ATTEMPTS=0
                    until [ \$(docker inspect -f '{{.State.Running}}' ${IMAGE_NAME}_temp) == "true" ] || [ \$ATTEMPTS -ge 5 ]; do
                      sleep 1
                      ATTEMPTS=\$((ATTEMPTS+1))
                    done
                    """

                    echo "New container is running on temp port"

                    // Зупиняємо старий контейнер на основному порту
                    sh """
                    CONTAINER_ID=\$(docker ps -q --filter "publish=${APP_PORT}")
                    if [ -n "\$CONTAINER_ID" ]; then
                      docker stop \$CONTAINER_ID
                      docker rm \$CONTAINER_ID
                    fi
                    """

                    // Переміщаємо новий контейнер на основний порт
                    sh """
                    docker stop ${IMAGE_NAME}_temp
                    docker rm ${IMAGE_NAME}_temp
                    docker run -d --name ${IMAGE_NAME}_${BRANCH_NAME} -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """

                    echo "Deployment completed with almost zero downtime"
                }
            }
        }
    }
}
