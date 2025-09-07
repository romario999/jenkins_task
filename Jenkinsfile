pipeline {
    agent any

    tools { nodejs 'node' }

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
                    TEMP_PORT = APP_PORT + 1000

                    echo "Branch: ${BRANCH_NAME}"
                    echo "Docker Image: ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    echo "App main port: ${APP_PORT}, temp port: ${TEMP_PORT}"
                }
            }
        }

        stage('Build') { steps { sh 'npm install' } }
        stage('Test')  { steps { sh 'npm test' } }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    sh "docker build -t ${IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Deploy Zero-Downtime') {
            steps {
                script {
                    // 1. Знаходимо старий контейнер (за портом)
                    OLD_CONTAINER = sh(
                        script: "docker ps -q --filter publish=${APP_PORT}",
                        returnStdout: true
                    ).trim()

                    // 2. Піднімаємо новий контейнер на TEMP_PORT
                    echo "Starting new container on temp port ${TEMP_PORT}"
                    sh "docker run -d -p ${TEMP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

                    // 3. Чекаємо, поки новий контейнер стартує
                    sleep(time: 5, unit: 'seconds') // можна додати перевірку curl на /health

                    // 4. Зупиняємо старий контейнер
                    if (OLD_CONTAINER) {
                        echo "Stopping old container ${OLD_CONTAINER}"
                        sh "docker stop ${OLD_CONTAINER} && docker rm ${OLD_CONTAINER}"
                    }

                    // 5. Перепідключаємо новий контейнер на основний порт
                    echo "Rebinding new container to main port ${APP_PORT}"
                    NEW_CONTAINER = sh(
                        script: "docker ps -q --filter publish=${TEMP_PORT}",
                        returnStdout: true
                    ).trim()
                    
                    sh "docker stop ${NEW_CONTAINER}"
                    sh "docker run -d -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
    }
}
