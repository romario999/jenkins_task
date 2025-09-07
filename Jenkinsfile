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

        stage('Deploy') {
            steps {
                script {
                    TEMP_PORT=$((APP_PORT + 1000))
                    echo "Deploying new container on temp port ${TEMP_PORT}"

                    sh "docker run -d --expose 3000 -p ${TEMP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

                    echo "Switching ports..."
                    sh """
                    OLD_CONTAINER=\$(docker ps -q --filter ancestor=${IMAGE_NAME}:${DOCKER_IMAGE_TAG})
                    if [ -n "\$OLD_CONTAINER" ]; then
                        docker stop \$OLD_CONTAINER
                        docker rm \$OLD_CONTAINER
                    fi
                    docker run -d --expose 3000 -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    docker stop \$(docker ps -q --filter "publish=${TEMP_PORT}")
                    docker rm \$(docker ps -a -q --filter "publish=${TEMP_PORT}")
                    """
                }
            }
        }
    }
}
