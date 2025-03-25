# Use an official OpenJDK runtime image as the base image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the application JAR file into the container
COPY web-app/build/libs/demo-0.0.1-SNAPSHOT.jar /app/myapp.jar

# Expose the application port
EXPOSE 8081

# Command to run the Java application
CMD ["java", "-jar", "/app/myapp.jar"]
