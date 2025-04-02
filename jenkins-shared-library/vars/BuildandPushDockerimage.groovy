#!usr/bin/env groovy
def call(String dockerHubCredentialsID, String repoName, String imageName, Srting imageTag) {
	withCredentials([usernamePassword(credentialsId: "${dockerHubCredentialsID}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
		sh "docker login -u ${USERNAME} -p ${PASSWORD}"
        	sh "docker build -t ${repoName}/${imageName}:${IMAGE_TAG} ."
        	sh "docker push ${repoName}/${imageName}:${IMAGE_TAG}"	 
        	sh "docker rmi ${repoName}/${imageName}:${IMAGE_TAG}"
  }
}