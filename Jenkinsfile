php_versions = ["5.6", "7.0", "7.1", "7.2", "7.3", "7.4"]

def buildPhpVersions(versions) {
    for (version in versions) {
        sh "docker build --build-arg php_version=${version} docker/magento"
    }
}

pipeline {
    agent {
        label 'docker'
    }

    stages {
        stage('Build Docker images') {
            steps {
                buildPhpVersions(php_versions)
                sh "docker build docker/nginx"
            }

            post {
                always {
                    deleteDir()
                }
            }
        }
    }
}
