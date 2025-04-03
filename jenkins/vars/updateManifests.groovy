def call(String DockerRegitry, String imageName, String imageTag, String deploymentFile) {
    sh "sed -i 's|image:.*|image: ${DockerRegitry}/${imageName}:${imageTag}|g' ${deploymentFile}"
}