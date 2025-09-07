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
                    TEMP_PORT = APP_PORT.toInteger() + 1000
                    echo "Deploying new container on temporary port ${TEMP_PORT}"

                    // Запуск нового контейнера на тимчасовому порту
                    sh """
                    docker run -d --name ${IMAGE_NAME}_temp -p ${TEMP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """

                    // Чекаємо, поки він підніметься
                    sh """
                    for i in {1..10}; do
                      if curl -s http://localhost:${TEMP_PORT} > /dev/null; then
                        echo "New container is up on port ${TEMP_PORT}"
                        break
                      fi
                      sleep 3
                    done
                    """

                    // Якщо старий контейнер існує — зупиняємо і видаляємо
                    sh """
                    CONTAINER_ID=\$(docker ps -q --filter "publish=${APP_PORT}")
                    if [ -n "\$CONTAINER_ID" ]; then
                      echo "Stopping old container on port ${APP_PORT}"
                      docker stop \$CONTAINER_ID
                      docker rm \$CONTAINER_ID
                    fi
                    """

                    // Запускаємо новий контейнер на основному порту
                    sh """
                    docker run -d --name ${IMAGE_NAME}_${BRANCH_NAME} -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """

                    // Видаляємо тимчасовий контейнер
                    sh "docker stop ${IMAGE_NAME}_temp || true && docker rm ${IMAGE_NAME}_temp || true"

                    echo "Deployment completed with minimal downtime"
                }
            }
        }
    }
}
