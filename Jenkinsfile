pipeline {
    agent any
    tools { nodejs 'node' }
    environment {
        DOCKER_IMAGE_TAG = "v1.0"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: env.BRANCH_NAME]],
                          userRemoteConfigs: [[url: 'git@github.com:romario999/jenkins_task.git']]])
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

        stage('Deploy with Minimal Downtime') {
            steps {
                script {
                    def containerName = "${env.IMAGE_NAME}_container"
                    def tempContainer = "${env.IMAGE_NAME}_temp"
                    def appPort = (env.BRANCH_NAME == 'main') ? 3000 : 3001
                    def tempPort = appPort + 100  // тимчасовий порт для запуску нового контейнера

                    // Зупинка тимчасового контейнера, якщо залишився
                    sh """
                    OLD_TEMP=\$(docker ps -q --filter "name=${tempContainer}")
                    if [ -n "\$OLD_TEMP" ]; then
                        docker stop \$OLD_TEMP
                        docker rm \$OLD_TEMP
                    fi
                    """

                    // Запуск нового контейнера на тимчасовому порту
                    sh "docker run -d --name ${tempContainer} --expose ${appPort} -p ${tempPort}:3000 ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

                    // Можна додати перевірку готовності сервісу на tempPort
                    echo "Waiting for new container to be ready..."
                    sh "sleep 5"  // або перевірка через curl/healthcheck

                    // Зупинка старого контейнера
                    sh """
                    OLD_CONTAINER=\$(docker ps -q --filter "name=${containerName}")
                    if [ -n "\$OLD_CONTAINER" ]; then
                        docker stop \$OLD_CONTAINER
                        docker rm \$OLD_CONTAINER
                    fi
                    """

                    // Перемикання нового контейнера на основний порт
                    sh "docker rename ${tempContainer} ${containerName}"
                    sh "docker stop ${containerName} || true"  // зупинка перед перезапуском на основному порту
                    sh "docker run -d --name ${containerName} --expose ${appPort} -p ${appPort}:3000 ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
    }
}
