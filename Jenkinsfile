pipeline {
    agent any

    tools {
    jdk 'jdk11'  // Must match JDK installation name in Jenkins
    maven 'maven-3.8.6'
}
    
    environment {
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/Docker.app/Contents/Resources/bin"
        
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'shebwell/javaweb3-calculator'  // Updated with your username
    }
    
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/shebwell/JavaWeb3.git',
                     branch: 'master'  // or 'main' based on your repo
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
                sh 'ls -la target/*.war' 
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_HUB_CREDENTIALS) {
                        docker.image("${DOCKER_IMAGE}:${env.BUILD_NUMBER}").push()
                        docker.image("${DOCKER_IMAGE}:${env.BUILD_NUMBER}").push('latest')
                    }
                }
            }
        }
    }
}
