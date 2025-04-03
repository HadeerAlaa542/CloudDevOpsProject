def call() {
    echo 'Running SonarQube analysis...'
    withSonarQubeEnv('sonarqube') {
        sh './gradlew sonar'
    }
}