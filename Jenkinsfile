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
                    
                    // Зберігаємо для наступних стадій
                    env.IMAGE_NAME = IMAGE_NAME
                    env.APP_PORT = "${APP_PORT}"
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
                    echo "Building Docker image: ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    sh "docker build -t ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Starting deployment of ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG} with minimal downtime"

                    def TEMP_PORT = (env.APP_PORT as int) + 1000
                    def TEMP_CONTAINER_NAME = "${env.IMAGE_NAME}_temp"

                    // Запускаємо новий контейнер на тимчасовому порту
                    sh """
                    echo "Running new container ${TEMP_CONTAINER_NAME} on port ${TEMP_PORT}"
                    docker run -d --name ${TEMP_CONTAINER_NAME} -p ${TEMP_PORT}:3000 ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """

                    // Знаходимо старий контейнер (не тимчасовий)
                    def OLD_CONTAINER_ID = sh(
                        script: "docker ps -q --filter 'name=^${env.IMAGE_NAME}\$'",
                        returnStdout: true
                    ).trim()

                    if (OLD_CONTAINER_ID) {
                        echo "Stopping old container ${OLD_CONTAINER_ID}"
                        sh "docker stop ${OLD_CONTAINER_ID} && docker rm ${OLD_CONTAINER_ID}"
                    } else {
                        echo "No old container found"
                    }

                    // Перемикаємо новий контейнер на основний порт
                    sh """
                    echo "Restarting new container ${TEMP_CONTAINER_NAME} on main port ${env.APP_PORT}"
                    docker stop ${TEMP_CONTAINER_NAME} && docker rm ${TEMP_CONTAINER_NAME}
                    docker run -d --name ${env.IMAGE_NAME} -p ${env.APP_PORT}:3000 ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    """

                    echo "Deployment completed successfully!"
                }
            }
        }
    }
}
