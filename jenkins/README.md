# Jenkins Pipeline for CloudDevOpsProject

This repository contains a Jenkins pipeline configuration for automating the build, test, and deployment of a Java web application (`CloudDevOpsProject`). The pipeline leverages Jenkins shared libraries, a Jenkins slave, and integrates with DockerHub and GitHub for continuous integration and deployment.

## Overview

The pipeline automates the following processes:
- Cloning the GitHub repository.
- Running unit tests.
- Building a JAR file.
- Running SonarQube test.
- Building and pushing a Docker image to DockerHub.
- Updating Kubernetes manifests with the new image tag.
- Pushing the updated manifests back to the GitHub repository.

The pipeline is defined in a `Jenkinsfile`, uses a shared library (`jenkins-shared-library`) for reusable steps, and runs on a configured Jenkins slave.

## Prerequisites

- **Jenkins Server**: Installed and configured with the necessary plugins (e.g., Git, Docker, Pipeline).
- **Jenkins Slave**: A configured Jenkins slave node labeled `jenkins-slave` (see "Configure Jenkins Slave" section below).
- **Docker**: Installed on the Jenkins slave for building and pushing Docker images.
- **GitHub Credentials**: Stored in Jenkins as `github` (ID: `github`).
- **DockerHub Credentials**: Stored in Jenkins as `dockerhub` (ID: `dockerhub`).
- **jenkins slave Credentials**: Stored in Jenkins as `jenkins-slave` (ID: `jenkins-slave`).
- **Shared Library**: Configured in Jenkins under "Manage Jenkins" > "Configure System" > "Global Pipeline Libraries" with the name `jenkins-shared-library` (see "Configure Jenkins Shared Library" section below).

## File Structure

The `jenkins` directory contains the pipeline configuration and shared library scripts:

```
jenkins/
├── Jenkinsfile                # Pipeline definition
└── vars/                      # Shared library directory
    ├── BuildandPushDockerimage.groovy  # Builds and pushes Docker image
    ├── buildJar.groovy         # Builds the JAR file
    ├── pushManifests.groovy    # Pushes updated manifests to GitHub
    ├── sonarQubeAnalysis.groovy # Runs SonarQube test 
    ├── unitTest.groovy         # Runs unit tests
    └── updateManifests.groovy  # Updates Kubernetes manifests
```

## Setup Instructions

1. **Clone the Repository**:
   - Ensure the repository (`https://github.com/HadeerAlaa542/CloudDevOpsProject.git`) is accessible.

2. **Configure Jenkins**:
   - Add GitHub credentials (`github`) , DockerHub credentials (`dockerhub`) and jenkins slave Credentials (`jenkins-slave`) in Jenkins under "Manage Credentials".

![image](https://github.com/user-attachments/assets/089eac5f-6314-4a90-be59-f644adf6bb77)

3. **Configure Jenkins Shared Library**:
   - Set up the `jenkins-shared-library` in Jenkins to provide reusable pipeline steps:
     1. **Navigate to Configuration**:
        - Go to "Manage Jenkins" > "Configure System" > "Global Pipeline Libraries".
     2. **Add the Library**:
        - Name: `jenkins-shared-library` (must match the `@Library` annotation in the `Jenkinsfile`).
        - Default Version: `main` (or the branch/tag where the shared library resides, e.g., `vars/` directory).
        - Load Implicitly: Unchecked (recommended, as it’s explicitly loaded in the `Jenkinsfile`).
        - Allow Default Version Override: Checked (optional, for flexibility).
        - Retrieval Method: "Modern SCM".
        - SCM: Git.
        - Repository URL: Point to the repository containing the `vars/` directory (e.g., `https://github.com/HadeerAlaa542/CloudDevOpsProject.git` if the library is in the same repo, or a separate repo if applicable).

     3. **Save Configuration**:
        - Save the settings to ensure the library is available to pipelines.

![image](https://github.com/user-attachments/assets/e9a72dd3-6133-4aa1-a1b0-b113f10e78dc)

![image](https://github.com/user-attachments/assets/39236bce-e665-4cf0-ab56-d5a8c829842e)

4. **Configure Jenkins Slave**:
   - Set up a Jenkins slave node to offload pipeline execution from the master:
     1. **Prepare the Slave Machine**:
        - Use a separate machine or VM with SSH access.
        - Install Java (required for the Jenkins agent), Git, and Docker.
     2. **Add Slave in Jenkins**:
        - Go to "Manage Jenkins" > "Manage Nodes and Clouds" > "New Node".
        - Name: e.g., `jenkins-slave-node`.
        - Type: Permanent Agent.
        - Labels: `jenkins-slave` (matches the `agent` label in the `Jenkinsfile`).
        - Launch Method: "Launch agent via SSH".
        - Host: IP address or hostname of the slave machine.
        - Credentials: Add SSH credentials (username and private key or password).
        - Host Key Verification Strategy: "Non-verifying" (or configure SSH keys properly).
     3. **Start the Slave**:
        - Save and launch the agent. Ensure it connects successfully (status: online).
     4. **Verify Tools**:
        - Confirm Git and Docker are accessible on the slave by running commands via Jenkins (e.g., `docker --version` in a pipeline step).

![image](https://github.com/user-attachments/assets/e07403e9-1071-4a4e-89e7-8116fef71144)

![image](https://github.com/user-attachments/assets/96c037ad-068d-4b73-b907-6895e698fb80)

![image](https://github.com/user-attachments/assets/beddd23d-8ba6-46f4-9916-b081b31e0148)

![image](https://github.com/user-attachments/assets/c6aba1e9-7ae6-4d67-9e08-5a7ae926c19a)


5. **Create the Pipeline**:
   - In Jenkins, create a new pipeline job.
   - Set the pipeline to use the `Jenkinsfile` from the repository (`https://github.com/HadeerAlaa542/CloudDevOpsProject.git`, branch: `main`).

6. **Run the Pipeline**:
   - Trigger the pipeline manually or configure a webhook for automatic triggering on code changes.

![image](https://github.com/user-attachments/assets/3b3956d1-940b-44b9-9d34-335a1865ed21)

## Jenkins Pipeline Stages

The pipeline (`Jenkinsfile`) includes the following stages, executed on the `jenkins-slave` agent using the `jenkins-shared-library`:

1. **Clone Repository**:
   - Clones the GitHub repository (`main` branch).

2. **Unit Test**:
   - Runs unit tests in the `FinalProjectCode/web-app` directory using the `unitTest()` shared library function.

3. **Build JAR**:
   - Builds the JAR file in the `FinalProjectCode/web-app` directory using the `buildJar()` shared library function.

4. **(SonarQube Analysis)**:
   - Runs SonarQube analysis in the `FinalProjectCode` directory using the `sonarQubeAnalysis()` shared library function.

5. **Manage Docker Image**:
   - Builds and pushes the Docker image to DockerHub using the `BuildandPushDockerimage()` shared library function.
   - Parameters: DockerHub credentials, registry (`hadeeralaa542`), image name (`java-web-app`), and tag (`v<BUILD_NUMBER>`).

6. **Update Manifests**:
   - Updates the Kubernetes deployment file (`deployment.yaml`) with the new image tag in the `kubernetes` directory using the `updateManifests()` shared library function.

7. **Push Manifests**:
   - Commits and pushes the updated manifests to the GitHub repository using the `pushManifests()` shared library function.

### Post-Build Actions
- **Success**: Prints "Deployment successful!" to the console.
- **Failure**: Prints "Build or deployment failed." to the console.

## Environment Variables

The pipeline uses the following environment variables:
- `GITHUB_REPO_URL`: GitHub repository URL.
- `REPO_NAME`: Repository name (`CloudDevOpsProject`).
- `GITHUB_REPO_BRANCH`: Branch to clone (`main`).
- `DOCKER_REGISTRY`: DockerHub username (`hadeeralaa542`).
- `DOCKER_IMAGE`: Docker image name (`java-web-app`).
- `IMAGE_TAG`: Image tag (`v<BUILD_NUMBER>`).
- `DOCKERHUB_CRED_ID`: Jenkins credential ID for DockerHub.
- `EMAIL`: Git commit email (`hadeeralaa542@gmail.com`).
- `GIT_USERNAME`: Git username (`Hadeer`).
- `GIT_CRED_ID`: Jenkins credential ID for GitHub.
- `DEPLOYMENT`: Kubernetes deployment file (`deployment.yaml`).

## Verification

1. **Pipeline Execution**:
   - Check the Jenkins console output for successful completion of all stages on the `jenkins-slave`.
   - Look for the "Deployment successful!" message in the post-build step.

2. **DockerHub**:
   - Verify the new image tag (`v<BUILD_NUMBER>`) is pushed to `hadeeralaa542/java-web-app` on DockerHub.

3. **GitHub**:
   - Confirm the `deployment.yaml` file in the `kubernetes` directory of the repository reflects the updated image tag.

## Troubleshooting

- **Shared Library Not Found**: Ensure the library name matches (`jenkins-shared-library`), the repository URL is correct, and credentials are set if required.
- **Slave Not Connecting**: Verify SSH credentials, network access, and Java installation on the slave.
- **Pipeline Fails**: Check the console output for errors in specific stages (e.g., missing credentials, file paths).
- **Docker Push Fails**: Ensure DockerHub credentials are correct and Docker is installed on the slave.
- **Git Push Fails**: Verify GitHub credentials and write access to the repository.

---
