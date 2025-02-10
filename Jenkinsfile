pipeline {
    agent any  // Use any available agent to run the pipeline

    environment {
        DOCKER_IMAGE = "todo-app:${env.BUILD_ID}"  // Set the Docker image name with a unique build ID
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/mahmoudsory/todo-app.git'  // Clone the repository
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."  // Build the Docker image with the specified name
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh "docker run -d -p 90:80 ${DOCKER_IMAGE}"  // Run the Docker container and map ports
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'  // Message on successful deployment
        }
        failure {
            echo 'Deployment failed!'  // Message on failure
        }
    }
}
