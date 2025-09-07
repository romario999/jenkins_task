pipeline {
    agent any

    tools {
        nodejs 'Node_7.8.0'
    }

    environment {
        BRANCH_NAME = env.BRANCH_NAME
        IMAGE_NAME = "node${BRANCH_NAME}"
        DOCKER_IMAGE_TAG = "v1.0"
        APP_PORT = (BRANCH_NAME == 'main') ? 3000 : 3001
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out ${BRANCH_NAME} branch"
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

        stage('Stop and Remove Previous Container') {
            steps {
                script {
                    echo "Stopping and removing previous container for port ${APP_PORT}"
                    sh """
                    CONTAINER_ID=\$(docker ps -q --filter ancestor=${IMAGE_NAME}:${DOCKER_IMAGE_TAG})
                    if [ -n "\$CONTAINER_ID" ]; then
                        echo "Found running container: \$CONTAINER_ID. Stopping..."
                        docker stop \$CONTAINER_ID
                        docker rm \$CONTAINER_ID
                    else
                        echo "No running container found."
                    fi
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying application on port ${APP_PORT} with image ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                    sh "docker run -d --expose 3000 -p ${APP_PORT}:3000 ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
    }
}
