# ==============================================================================
# TeenFounders Network - Velocity Proxy Production Dockerfile
# Eclipse Temurin OpenJDK 21 Runtime
# ==============================================================================

FROM eclipse-temurin:21-jre-alpine

ENV VELOCITY_VERSION="3.3.0-SNAPSHOT" \
    PORT="25565"

RUN apk add --no-cache curl jq bash netcat-openbsd ca-certificates tzdata

WORKDIR /proxy

# Download Velocity Proxy build
RUN curl -sSL "https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/398/downloads/velocity-3.3.0-SNAPSHOT-398.jar" -o /proxy/velocity.jar || \
    curl -sSL "https://versions.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/398/downloads/velocity-3.3.0-SNAPSHOT-398.jar" -o /proxy/velocity.jar

COPY velocity.toml /proxy/velocity.toml
COPY secret.txt /proxy/forwarding.secret

EXPOSE 25565/tcp

ENTRYPOINT ["java", "-Xms1G", "-Xmx1G", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled", "-XX:+AlwaysPreTouch", "-jar", "velocity.jar"]
