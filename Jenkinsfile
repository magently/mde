pipeline {
    agent {
        label 'docker'
    }

    stages {
        stage('Build image') {
            steps {
                sh '[ ! -e docker/magento ] || docker build docker/magento'
                sh '[ ! -e docker/nginx ] || docker build docker/nginx'
            }

            post {
                always {
                    deleteDir()
                }
            }
        }

    }
}
