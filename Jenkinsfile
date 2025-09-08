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
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: env.BRANCH_NAME]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    userRemoteConfigs: [[
                        url: 'git@github.com:romario999/jenkins_task.git',
                    ]]
                ])
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_NAME = (env.BRANCH_NAME == 'main') ? "nodemain" : "nodedev"
                    sh "docker build -t ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def containerName = "${env.IMAGE_NAME}_container"
                    def appPort = (env.BRANCH_NAME == 'main') ? 3000 : 3001

                    // Функція для зупинки контейнера по імені
                    sh """
                    CONTAINER_ID=\$(docker ps -q --filter "name=${containerName}")
                    if [ -n "\$CONTAINER_ID" ]; then
                        echo "Stopping previous container: \$CONTAINER_ID"
                        docker stop \$CONTAINER_ID
                        docker rm \$CONTAINER_ID
                    fi
                    """

                    // Запуск нового контейнера
                    sh "docker run -d --name ${containerName} --expose ${appPort} -p ${appPort}:3000 ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished for branch ${env.BRANCH_NAME}"
        }
        failure {
            echo "Build failed!"
        }
    }
}
