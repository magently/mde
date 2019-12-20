pipeline {
    agent {
        label 'docker'
    }

    stages {
        stage('Build image') {
            steps {
                sh 'docker build --build-arg php_version=7.1 docker/magento'
                sh 'docker build docker/nginx'
            }

            post {
                always {
                    deleteDir()
                }
            }
        }

    }
}
