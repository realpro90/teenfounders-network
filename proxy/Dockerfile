# ==============================================================================
# TeenFounders Network - Velocity Proxy Production Dockerfile
# Eclipse Temurin OpenJDK 21 Runtime
# ==============================================================================

FROM eclipse-temurin:21-jre-alpine

ENV VELOCITY_VERSION="3.3.0-SNAPSHOT" \
    PORT="25565"

RUN apk add --no-cache curl jq bash netcat-openbsd ca-certificates tzdata

WORKDIR /proxy

# Download Velocity Proxy build from direct mirror
RUN curl -sSL "https://ci.papermc.io/job/Velocity/lastSuccessfulBuild/artifact/proxy/target/velocity-proxy-3.3.0-SNAPSHOT.jar" -o /proxy/velocity.jar || \
    curl -sSL "https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/398/downloads/velocity-3.3.0-SNAPSHOT-398.jar" -o /proxy/velocity.jar || \
    curl -sSL "https://api.purpurmc.org/v2/purpur/1.21.4/latest/download" -o /proxy/velocity.jar

COPY proxy/velocity.toml /proxy/velocity.toml
COPY proxy/secret.txt /proxy/forwarding.secret

EXPOSE 25565/tcp

ENTRYPOINT ["java", "-Xms1G", "-Xmx1G", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled", "-XX:+AlwaysPreTouch", "-jar", "velocity.jar"]
