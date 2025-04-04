def call() {
    echo 'Running SonarQube analysis...'
    sh './gradlew clean build'
    sh './gradlew sonar'
}  