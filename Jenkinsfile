pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code from Git...'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '📦 Installing Node.js dependencies...'
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                echo '✅ Running tests...'
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    sh 'docker build -t jenkins-demo-app:${BUILD_NUMBER} .'
                    sh 'docker tag jenkins-demo-app:${BUILD_NUMBER} jenkins-demo-app:latest'
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                echo '🧪 Testing Docker image...'
                script {
                    sh 'docker images | grep jenkins-demo-app'
                }
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Deploying application...'
                script {
                    def containerName = "jenkins-demo-app-${BUILD_NUMBER}"

                    // עצירת קונטיינרים קיימים עם שם דומה (אם יש)
                    sh """
                    docker ps -a --filter "name=jenkins-demo-app" --format "{{.ID}}" | xargs -r docker stop
                    docker ps -a --filter "name=jenkins-demo-app" --format "{{.ID}}" | xargs -r docker rm
                    """

                    // הרצת הקונטיינר החדש
                    sh "docker run -d --name ${containerName} -p 3000:3000 jenkins-demo-app:${BUILD_NUMBER}"

                    // השהייה כדי שהאפליקציה תעלה
                    sh "sleep 5"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '🔍 Verifying deployment...'
                // ביצוע קריאת health מחוץ לקונטיינר
                sh 'curl -f http://localhost:3000/health || (echo "Health check failed" && exit 1)'
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up old images...'
            script {
                // מחיקת תמונות ישנות למעט הנוכחית
                sh '''
                docker images jenkins-demo-app --format "{{.ID}} {{.Tag}}" | grep -v latest | grep -v ${BUILD_NUMBER} | awk '{print $1}' | xargs -r docker rmi -f || true
                '''
            }
        }

        failure {
            echo '❌ Pipeline failed! Check logs.'
        }
    }
}
