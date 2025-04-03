def call() {
    sh 'chmod +x gradlew'
    sh './gradlew test'
}