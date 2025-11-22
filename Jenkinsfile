pipeline {
    agent any

    environment {
        DOCKERHUB_USER     = "francogbb"
        DOCKERHUB_REPO     = "backend-test"
        IMAGE_NAME         = "backend-test"
        BUILD_TAG_NUMBER   = "${BUILD_NUMBER}"
        GHCR_OWNER         = "francogbb"   
        GHCR_IMAGE         = "ghcr.io/${GHCR_OWNER}/${IMAGE_NAME}"
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

        stage('Docker build image') {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME} .
                """
            }
        }

        stage('Docker hub push') {
            steps {
                script {
                    docker.withRegistry("https://index.docker.io/v1/", "token-docker") {

                        sh "docker tag ${IMAGE_NAME} ${DOCKERHUB_USER}/${DOCKERHUB_REPO}"
                        sh "docker tag ${IMAGE_NAME} ${DOCKERHUB_USER}/${DOCKERHUB_REPO}:${BUILD_TAG_NUMBER}"

                        sh "docker push ${DOCKERHUB_USER}/${DOCKERHUB_REPO}"
                        sh "docker push ${DOCKERHUB_USER}/${DOCKERHUB_REPO}:${BUILD_TAG_NUMBER}"
                    }
                }
            }
        }

        stage('Github push') {
            steps {
                script {
                    docker.withRegistry("https://ghcr.io", "token-github") {

                        sh "docker tag ${IMAGE_NAME} ${GHCR_IMAGE}"
                        sh "docker tag ${IMAGE_NAME} ${GHCR_IMAGE}:${BUILD_TAG_NUMBER}"

                        sh "docker push ${GHCR_IMAGE}"
                        sh "docker push ${GHCR_IMAGE}:${BUILD_TAG_NUMBER}"
                    }
                }
            }
        }
        stage('Kubernetes update') {
            agent {
                docker{
                    image 'alpine/k8s:1.32.2'
                    reuseNode true
                }
            }
            steps {
                withKubeConfig([credentialsId: 'kubeconfig-docker']){
                    sh "kubectl -n fgarrido set image deployments backend-test backend=${DOCKERHUB_USER}/${DOCKERHUB_REPO}:${BUILD_TAG_NUMBER}"
                }
            }
        }
    }
}
