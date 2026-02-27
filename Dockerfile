# Stage 1: Build stage
FROM maven:3.9.6-eclipse-temurin-21 AS builder

# Set working directory
WORKDIR /app

# Copy parent pom.xml first
COPY pom.xml ./

# Copy api-gateway pom.xml (artifactId is api-gateway)
COPY Stealz-Gateway/pom.xml ./Stealz-Gateway/

# Download dependencies (layer caching optimization)
RUN mvn dependency:go-offline -pl Stealz-Gateway -am

# Copy source code
COPY Stealz-Gateway/src ./Stealz-Gateway/src

# Build the application (skip tests for faster builds)
RUN mvn clean package -pl Stealz-Gateway -am -DskipTests

# Stage 2: Runtime stage
FROM eclipse-temurin:21-jre-alpine

# Add metadata
LABEL maintainer="ecommerce-team"
LABEL service="stealz-gateway"

# Create non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring

# Set working directory
WORKDIR /app

# Copy the JAR from builder stage
COPY --from=builder /app/Stealz-Gateway/target/*.jar app.jar

# Change ownership to non-root user
RUN chown spring:spring app.jar

# Switch to non-root user
USER spring

# Environment variables for Spring profiles and JVM optimization
ENV SPRING_PROFILES_ACTIVE=dev \
    JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Expose the service port (Spring Cloud Gateway default)
EXPOSE 8080

# Health check using Spring Boot Actuator
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
