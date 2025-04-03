def call(String repoName, String username, String email, String gitHubCredId) {
    withCredentials([sshUserPrivateKey(credentialsId: gitHubCredId, keyFileVariable: 'SSH_KEY')]) {
        sh """
            eval \$(ssh-agent -s)
            ssh-add ${SSH_KEY}
            ssh -o StrictHostKeyChecking=no -T git@github.com || true  # Accept host key, ignore failure
            git remote set-url origin git@github.com:HadeerAlaa542/${repoName}.git
            git config --global user.email "${email}"
            git config --global user.name "${username}"
            git add .
            git commit -m "Push Manifests" || echo "Nothing to commit"
            git push origin main
            ssh-agent -k  # Clean up
        """
    }
}