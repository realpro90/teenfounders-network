# ==============================================================================
# TeenFounders Network - Proxy Production Dockerfile
# Eclipse Temurin OpenJDK 21 Runtime with Railway IPv6 Mesh Support
# ==============================================================================

FROM eclipse-temurin:21-jre-alpine

ENV PORT="25565"

RUN apk add --no-cache curl jq bash netcat-openbsd ca-certificates tzdata

WORKDIR /proxy

# Download Proxy engine build (BungeeCord / Waterfall)
RUN curl -sSL "https://hub.spigotmc.org/jenkins/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar" -o /proxy/proxy.jar

COPY proxy/config.yml /proxy/config.yml
COPY proxy/velocity.toml /proxy/velocity.toml
COPY proxy/secret.txt /proxy/forwarding.secret
COPY proxy/server-icon.png /proxy/server-icon.png

EXPOSE 25565/tcp

ENTRYPOINT ["java", "-Djava.net.preferIPv6Addresses=true", "-Xms1G", "-Xmx1G", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled", "-XX:+AlwaysPreTouch", "-jar", "proxy.jar"]
