# =========================
# Stage 1: Build
# =========================
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /build

COPY pom.xml .

RUN --mount=type=cache,target=/root/.m2 \
    mvn -B dependency:go-offline

COPY src ./src
RUN --mount=type=cache,target=/root/.m2 \
     mvn -B clean install -DskipTests

# =========================
# Stage 2: Runtime
# =========================
FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache ttf-dejavu

RUN mkdir -p /tmp/logs

VOLUME /tmp

# Copiamos el JAR desde el stage de backend
COPY --from=build /build/target/rojasgov-gateway-1.0.0.jar /app.jar

ENTRYPOINT ["sh", "-c", "java \
  -Duser.timezone=America/Argentina/Buenos_Aires \
  -Djava.security.egd=file:/dev/./urandom \
  -Djava.awt.headless=true \
  -jar /app.jar"]
