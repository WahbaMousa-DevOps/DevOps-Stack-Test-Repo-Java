# Purpose: Build and package the Java app into a lightweight runtime image.
# Used during CI to build, then deploy to production.
# Multi-stage:
# Stage 1: Use JDK to compile.
# Stage 2: Use JRE only (no compiler) → smaller, secure image.
# Used For: Running the app in production (not for building).
# This is your Java App Image — lightweight and deployable.
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