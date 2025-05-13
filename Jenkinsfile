pipeline {
    agent any
    
    tools {
        maven 'maven-3.8.6'
        jdk 'jdk11'
    }
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'shebwell/javaweb3-calculator'
        DOCKER_PATH = '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/Docker.app/Contents/Resources/bin'
    }
    
    stage('Checkout') {
  steps {
    checkout([
      $class: 'GitSCM',
      branches: [[name: '*/master']],
      extensions: [
        [$class: 'CleanBeforeCheckout']  // Cleans workspace before checkout
      ],
      userRemoteConfigs: [[url: 'https://github.com/shebwell/JavaWeb3.git']]
  }
}
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
                sh 'ls -la target/*.war'
            }
        }
        
        stage('Build Docker Image') {
            environment {
                PATH = "${env.DOCKER_PATH}"
            }
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                }
            }
        }
        
        stage('Push to Docker Hub') {
            environment {
                PATH = "${env.DOCKER_PATH}"
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_HUB_CREDENTIALS) {
                        docker.image("${DOCKER_IMAGE}:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed - cleaning up workspace'
            cleanWs()
        }
        }
    }
}
