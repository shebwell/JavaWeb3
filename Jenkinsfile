pipeline {
    agent any
    
    tools {
        maven 'maven-3.8.6'       // Maven installation configured in Jenkins
        jdk 'jdk11'               // JDK 11 installation configured in Jenkins
    }
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')  // Jenkins credential ID
        DOCKER_IMAGE = 'shebwell/javaweb3-calculator'  // Your Docker Hub repository
        VERSION = "${env.BUILD_NUMBER}"               // Version tag for Docker image
        DOCKER_PATH = '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/Docker.app/Contents/Resources/bin'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',  // or 'main' based on your repo
                     url: 'https://github.com/shebwell/JavaWeb3.git'
            }
        }
        
        stage('Build & Test') {
            steps {
                sh 'mvn clean package'
                sh 'ls -la target/*.war'  // Verify WAR file exists
            }
            
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                }
            }
        }
        
        stage('Build Docker Image') {
            environment {
                PATH = "${env.DOCKER_PATH}"  // Ensure Docker is in PATH
            }
            steps {
                script {
                    // Build with BuildKit support and cache
                    dockerImage = docker.build(
                        "${DOCKER_IMAGE}:${VERSION}",
                        "--build-arg BUILDKIT_INLINE_CACHE=1 ."
                    )
                }
            }
        }
        
        stage('Push to Docker Hub') {
            environment {
                PATH = "${env.DOCKER_PATH}"  // Ensure Docker is in PATH
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_HUB_CREDENTIALS) {
                        dockerImage.push()
                        dockerImage.push('latest')  // Also push as latest
                    }
                }
            }
        }
        
        stage('Deploy (Optional)') {
            steps {
                echo 'Deployment would happen here'
                // Example: sh 'kubectl apply -f k8s-deployment.yaml'
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed - cleaning up workspace'
            cleanWs()  // Clean up workspace
        }
        success {
            slackSend color: 'good', message: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
        failure {
            slackSend color: 'danger', message: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            emailext body: 'Check ${BUILD_URL}', subject: 'Pipeline Failed', to: 'team@example.com'
        }
    }
}
