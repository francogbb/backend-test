pipeline {
    agent any

    environment {
        DOCKERHUB_USER     = "francogbb"
        DOCKERHUB_REPO     = "backend-test"
        IMAGE_NAME         = "backend-test"
        BUILD_TAG_NUMBER   = "${BUILD_NUMBER}"
    }

    stages {

        stage('Procesar app con Docker') {
            agent {
                docker {
                    image 'node:22-alpine'
                }
            }

            stages {
                stage('Instalación dependencias') {
                    steps {
                        sh 'npm install'
                    }
                }

                stage('Testing') {
                    steps {
                        sh 'npm run test:cov'
                    }
                }

                stage('Build') {
                    steps {
                        sh 'npm run build'
                    }
                }
            }
        }

        stage('Docker image build') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."

                sh "docker tag ${IMAGE_NAME} ${DOCKERHUB_USER}/${DOCKERHUB_REPO}"
                sh "docker tag ${IMAGE_NAME} ${DOCKERHUB_USER}/${DOCKERHUB_REPO}:${BUILD_TAG_NUMBER}"

                script {
                    docker.withRegistry("https://index.docker.io/v1/", "token-jenkins") {

                        sh "docker push ${DOCKERHUB_USER}/${DOCKERHUB_REPO}"
                        sh "docker push ${DOCKERHUB_USER}/${DOCKERHUB_REPO}:${BUILD_TAG_NUMBER}"
                    }
                }
            }
        }
    }
}
