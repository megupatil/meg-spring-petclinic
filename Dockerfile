# Use OpenJDK 17 as the base image for Spring Boot 3.x compatibility
FROM eclipse-temurin:17-jre-alpine

# Set working directory
WORKDIR /app

# Create a non-root user for security
RUN addgroup -S appuser && adduser -S -G appuser appuser

# Copy the JAR file from the build context
# The JAR_FILE build arg will be passed from the pipeline
ARG JAR_FILE
COPY ${JAR_FILE} app.jar

# Change ownership to the non-root user
RUN chown appuser:appuser app.jar

# Switch to non-root user
USER appuser

# Expose the default Spring Boot port
EXPOSE 8080

# Set JVM options for containerized environments
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
