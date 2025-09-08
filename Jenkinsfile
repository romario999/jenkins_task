pipeline {
    agent any

    tools {
        nodejs 'node' // Назва NodeJS, яку ти вказав у "Global Tool Configuration"
    }

    environment {
        DOCKER_IMAGE_TAG = "v1.0"
    }

    stages {
        stage('Checkout') {
            steps {
                // Використовуємо SSH ключі Jenkins для GitHub
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
                    if (env.BRANCH_NAME == 'main') {
                        env.IMAGE_NAME = "nodemain"
                    } else {
                        env.IMAGE_NAME = "nodedev"
                    }
                    sh "docker build -t ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def containerName = "${env.IMAGE_NAME}_container"
                    def portMapping = (env.BRANCH_NAME == 'main') ? "3000:3000" : "3001:3000"
                    def exposePort = (env.BRANCH_NAME == 'main') ? "3000" : "3001"

                    // Зупинити і видалити попередні контейнери
                    sh """
                        CONTAINER_ID=\$(docker ps -q --filter "name=${containerName}")
                        if [ -n "\$CONTAINER_ID" ]; then
                            echo "Stopping previous container..."
                            docker stop \$CONTAINER_ID
                            docker rm \$CONTAINER_ID
                        fi
                    """

                    // Запустити новий контейнер
                    sh "docker run -d --name ${containerName} --expose ${exposePort} -p ${portMapping} ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
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
