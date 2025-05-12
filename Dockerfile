# Build stage
FROM maven:3.8.6-openjdk-11-slim AS build
WORKDIR /app

# Copy only the POM first to leverage Docker cache
COPY pom.xml .
# Download dependencies
RUN mvn dependency:go-offline

# Copy source code
COPY src/ /app/src/
# Build the application
RUN mvn package -DskipTests

# Runtime stage
FROM openjdk:11-jre-slim
WORKDIR /app

# Copy the built WAR file from build stage
COPY --from=build /app/target/JavaWeb3.war /app/JavaWeb3.war

# Expose port 8080
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "JavaWeb3.war"]
