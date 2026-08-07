# ==============================================================================
# TeenFounders Network - Proxy Production Dockerfile
# Eclipse Temurin OpenJDK 21 Runtime with Pre-Bundled BungeeCord Modules
# ==============================================================================

FROM eclipse-temurin:21-jre-alpine

ENV PORT="25565"

RUN apk add --no-cache curl jq bash netcat-openbsd ca-certificates tzdata

WORKDIR /proxy

# 1. Download BungeeCord Proxy Engine Build
RUN curl -sSL "https://hub.spigotmc.org/jenkins/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar" -o /proxy/proxy.jar

# 2. Pre-bundle BungeeCord modules into /proxy/modules to prevent runtime download failures
RUN mkdir -p /proxy/modules && \
    curl -sSL "https://hub.spigotmc.org/jenkins/job/BungeeCord/lastSuccessfulBuild/artifact/module/cmd-alert/target/cmd_alert.jar" -o /proxy/modules/cmd_alert.jar || true && \
    curl -sSL "https://hub.spigotmc.org/jenkins/job/BungeeCord/lastSuccessfulBuild/artifact/module/cmd-find/target/cmd_find.jar" -o /proxy/modules/cmd_find.jar || true && \
    curl -sSL "https://hub.spigotmc.org/jenkins/job/BungeeCord/lastSuccessfulBuild/artifact/module/cmd-list/target/cmd_list.jar" -o /proxy/modules/cmd_list.jar || true && \
    curl -sSL "https://hub.spigotmc.org/jenkins/job/BungeeCord/lastSuccessfulBuild/artifact/module/cmd-send/target/cmd_send.jar" -o /proxy/modules/cmd_send.jar || true && \
    curl -sSL "https://hub.spigotmc.org/jenkins/job/BungeeCord/lastSuccessfulBuild/artifact/module/cmd-server/target/cmd_server.jar" -o /proxy/modules/cmd_server.jar || true && \
    curl -sSL "https://hub.spigotmc.org/jenkins/job/BungeeCord/lastSuccessfulBuild/artifact/module/reconnect-yaml/target/reconnect_yaml.jar" -o /proxy/modules/reconnect_yaml.jar || true

COPY proxy/config.yml /proxy/config.yml
COPY proxy/velocity.toml /proxy/velocity.toml
COPY proxy/secret.txt /proxy/forwarding.secret
COPY proxy/server-icon.png /proxy/server-icon.png

EXPOSE 25565/tcp

# Run BungeeCord with preferIPv6Addresses for Railway mesh DNS resolution
ENTRYPOINT ["java", "-Djava.net.preferIPv6Addresses=true", "-Xms1G", "-Xmx1G", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled", "-XX:+AlwaysPreTouch", "-jar", "proxy.jar"]
