#!usr/bin/env groovy
def call(String dockerHubCredentialsID, String repoName, String imageName, String imageTag) {
	withCredentials([usernamePassword(credentialsId: "${dockerHubCredentialsID}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
		sh "docker login -u ${USERNAME} -p ${PASSWORD}"
        	sh "docker build -t ${repoName}/${imageName}:${imageTag} ."
        	sh "docker push ${repoName}/${imageName}:${imageTag}"	 
        	sh "docker rmi ${repoName}/${imageName}:${imageTag}"
  }
}