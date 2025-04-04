### **1. GitHub Repository Setup**
#### **Task:**
- Create a GitHub repository named **"CloudDevOpsProject"**.
- Initialize it with a **README**.

#### **Steps:**
1. Go to [GitHub](https://github.com/).
2. Click on **New Repository**.
3. Name it **CloudDevOpsProject**.
4. Select **Public** or **Private** based on your preference.
5. Check the option **Initialize this repository with a README**.
6. Click **Create Repository**.

---

### **2. Containerization with Docker**
#### **Task:**
- Create a **Dockerfile** to build the application image.
- Use the source code from:  
  [https://github.com/IbrahimAdell/FinalProjectCode.git](https://github.com/IbrahimAdell/FinalProjectCode.git).

#### **Steps:**

1. Clone the app repository:
   ```bash
    git clone git@github.com:IbrahimAdell/FinalProjectCode.git 
    rm -r FinalProjectCode/
    git add  .
    git commit -m "add source code" 
    git push origin main
   ```
   
2. Run unit tests:
   ```bash
   chmod +x gradlew
   ./gradlew test
   ```
![image](https://github.com/user-attachments/assets/90116d12-c012-4b7c-a8f3-58457513f3af)

3. Build the JAR file :
   ```bash
   ./gradlew build
   ```
![image](https://github.com/user-attachments/assets/03952c86-2e68-4e77-9a64-e5a8e36fb9f6)

 
4. Run the app:
   ```bash
   java -jar target/*.jar
   ```
![image](https://github.com/user-attachments/assets/7292d955-e40c-4e65-bee8-f85df79f0a06)

5. Open the app in a browser at `http://localhost:8081` (or the port used).

![image](https://github.com/user-attachments/assets/96641e37-4a2d-4e26-aa07-f6c03b70d694)

![image](https://github.com/user-attachments/assets/16431706-1701-4bda-a9e3-c86f01068747)

##### **(2) Install and Use SonarQube**
1. Install SonarQube manually on your local machine.
2. Run SonarQube and scan your project:
   ```bash
   sonar-scanner
   ```
3. Analyze the test results in SonarQube.

##### **(3) Dockerization**
1. Create a **Dockerfile** in the root of your project:
   ```dockerfile
   FROM openjdk:17-jdk-slim
   WORKDIR /app
   COPY web-app/build/libs/demo-0.0.1-SNAPSHOT.jar /app/myapp.jar
   EXPOSE 8081
   CMD ["java", "-jar", "/app/myapp.jar"]
   ```
2. Build the Docker image:
   ```bash
   docker build -t my-java-app .
   ```
![image](https://github.com/user-attachments/assets/4c6f1600-4a0e-4204-ae3d-117ec0062ca5)

3. Run the container:
   ```bash
   docker run -d -p 8081:8081 java-app my-java-app
   ```
![image](https://github.com/user-attachments/assets/a7530ece-cfd9-4882-adb1-70db709b172d)

4. verify the container is running
   ```bash
   docker ps -a
   ```
![image](https://github.com/user-attachments/assets/157e91a6-d19e-4e54-ba25-56b069d90b72)

5.  Open the app in a browser at `http://localhost:8081`.

![image](https://github.com/user-attachments/assets/7b7e41bd-dc85-49df-a83f-66b41c7f3b67)

6. Push the image to DockerHub
  ```bash
   docker login
   docker push your-dockerhub-username/java-web-app:v1 
   ```
   
