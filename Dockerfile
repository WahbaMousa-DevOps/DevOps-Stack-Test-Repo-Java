# Build stage
FROM gradle:8.5-jdk17 AS build
WORKDIR /app

# Copy gradle configuration
COPY gradle gradle/
COPY build.gradle settings.gradle gradlew ./

# Download dependencies
RUN ./gradlew dependencies

# Copy source code
COPY src ./src/

# Build application
RUN ./gradlew build -x test

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Build arguments
ARG APP_VERSION=dev
ARG BUILD_NUMBER=0
ARG GIT_COMMIT=unknown

# Set labels with build information
LABEL org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.vendor="Your Organization" \
      org.opencontainers.image.title="Java Sample Application" \
      org.opencontainers.image.description="Java Spring Boot Sample Application" \
      build.number="${BUILD_NUMBER}"

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy application JAR from build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Set permissions
RUN chown -R appuser:appgroup /app

# Set environment variables
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"
ENV SPRING_PROFILES_ACTIVE="production"

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD wget -q --spider http://localhost:8080/actuator/health || exit 1

# Expose application port
EXPOSE 8080

# Run application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
