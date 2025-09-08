pipeline {
    agent any

    tools {
        nodejs 'node'
    }

    environment {
        DOCKER_IMAGE_TAG = "v1.0"
        DOCKER_CREDENTIALS = "docker-hub-creds"
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

       stage('Scan Docker image for vulnerabilities') {
            steps {
                script {
                    withEnv(["TRIVY_CACHE_DIR=${WORKSPACE}/.trivy-cache"]) {
                        def vulnerabilities = sh(
                            script: "trivy image --exit-code 0 --severity HIGH,MEDIUM,LOW --no-progress ${env.IMAGE_NAME}:${DOCKER_IMAGE_TAG}",
                            returnStdout: true
                        ).trim()
                        echo "Vulnerability report: \n${vulnerabilities}"
                    }
                }
            }
        }

       stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh '''#!/bin/bash
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag ${IMAGE_NAME}:${DOCKER_IMAGE_TAG} $DOCKER_USER/${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                        docker push $DOCKER_USER/${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                        '''
                        }
                    }
            }
    }

        stage('Trigger Deploy Pipeline') {
            steps {
                script {
                    def deployJob = (env.BRANCH_NAME == 'main') ? "Deploy_to_main" : "Deploy_to_dev"
                    build job: deployJob, wait: false, parameters: [
                        string(name: 'IMAGE_NAME', value: "${env.IMAGE_NAME}"),
                        string(name: 'IMAGE_TAG', value: "${DOCKER_IMAGE_TAG}")
                    ]
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished for branch ${env.BRANCH_NAME}"
            sh "docker ps -a -q --filter 'status=exited' | xargs -r docker rm"
            sh "docker image prune -f"
        }
        failure {
            echo "Build failed!"
        }
    }
}
