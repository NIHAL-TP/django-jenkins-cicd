pipeline {

    agent {label 'agent-1'}


    stages {

        stage('Git Checkout') {

            steps {

                git branch: 'main', credentialsId: 'b1648b26-a77a-4f7c-957c-0f74696ef9e8', url: 'https://github.com/NIHAL-TP/django-jenkins-cicd.git'

            }

        }

        stage(' Build') {

            steps {

                sh '''

                    pwd

                    cd collaborative_editor

                    pwd

                    docker buildx build --platform linux/amd64 -t collaborative-editor-app .
                    
                '''
            }

        }

        stage('Push To Docker Hub') {

            steps {

                withCredentials([usernamePassword('credentialsId':'DockerHub','passwordVariable':'dockerHubPass','usernameVariable':'dockerHubUser')])

                {

                    sh """docker login -u "${env.dockerHubUser}" -p "${env.dockerHubPass}"

                          docker tag collaborative-editor-app:latest "${env.dockerHubUser}"/collaborative-editor-app:latest

                          docker push "${env.dockerHubUser}"/collaborative-editor-app"""

                }

                

            }

        }

        stage('Test') {

            steps {

                sh '''

                    docker run -v $WORKSPACE:/app collaborative-editor-app bash -c "

                        pip install --upgrade pip &&  # Optional: Upgrade pip to avoid warning

                        pip install bandit flake8 &&

                        bandit -r /app > /app/bandit_report.txt || true &&

                        flake8 /app > /app/flake8_report.txt || true

                    "

                '''

                archiveArtifacts artifacts: 'bandit_report.txt, flake8_report.txt', allowEmptyArchive: true

                sh 'cat bandit_report.txt' // Optional

                sh 'cat flake8_report.txt' // Optional

            }

        }

            stage('Pull and Run Docker Image') {
        steps {
            withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'dockerHubPass', usernameVariable: 'dockerHubUser')]) {
                sh '''
                    docker login -u "${dockerHubUser}" -p "${dockerHubPass}"
                    docker pull "${dockerHubUser}/collaborative-editor-app:latest" 
                    docker stop collaborative-editor-app || true
                    docker rm collaborative-editor-app || true
                    docker run -d -p 8000:8000 --name collaborative-editor-app "${dockerHubUser}/collaborative-editor-app:latest"
                '''
            }
        }
    }
    
    stage('Reverse Proxy Configuration (on Agent)') {
        steps {
            sh '''
                sudo nginx -t && sudo systemctl restart nginx
            '''
        }
    }

    }

    

}

