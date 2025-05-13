# Build stage
FROM maven:3.8.6-openjdk-11-slim AS build

WORKDIR /app

# First copy only the POM file to cache dependencies
COPY pom.xml .

# Download dependencies (this layer gets cached unless POM changes)
RUN mvn dependency:go-offline -B

# Copy all source files
COPY src ./src

# Build the application (skip tests for faster builds)
RUN mvn package -DskipTests

# Verify the built WAR file exists and is named correctly
RUN ls -la /app/target/*.war

# Runtime stage - start with clean, small image
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy the WAR file from build stage
# Using wildcard to handle any WAR filename
COPY --from=build /app/target/*.war /app/application.war

# Expose port 8080 (the default Tomcat/Spring Boot port)
EXPOSE 8080

# Health check (optional but recommended)
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/JavaWeb3/ || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "application.war"]
