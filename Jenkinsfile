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
            echo "Deploying ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

            // Зупиняємо старий контейнер, якщо він є
            def OLD_CONTAINER_ID = sh(
                script: "docker ps -q --filter 'name=^${env.IMAGE_NAME}\$'",
                returnStdout: true
            ).trim()

            if (OLD_CONTAINER_ID) {
                echo "Stopping old container ${OLD_CONTAINER_ID}"
                sh "docker stop ${OLD_CONTAINER_ID} && docker rm ${OLD_CONTAINER_ID}"
            }

            // Запускаємо новий контейнер на основному порту
            sh "docker run -d --name ${env.IMAGE_NAME} -p ${env.APP_PORT}:3000 ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
            echo "Deployment completed successfully!"
        }
    }
}

    }
}
