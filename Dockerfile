# Build stage
FROM openjdk:17-jdk-slim-buster AS builder
WORKDIR /app
COPY Main.java .
RUN javac Main.java

# Runtime stage with security hardening
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /app/Main.class .

# Non-root user setup
RUN adduser --disabled-login --no-create-home --gecos '' appuser \
    && chown -R appuser:appuser /app
USER appuser

# Runtime configuration
CMD ["java", "Main"]