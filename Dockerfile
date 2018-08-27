FROM maven-3-jdk-8 AS builder
WORKDIR /usr/src/app

# Caching dependencies
COPY pom.xml ./pom.xml
RUN mvn dependency:go-offline -B

# Build source
COPY ./src ./src
RUN mvn package

FROM openjdk:8-alpine
WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/target/*.jar ./app.jar
CMD [ "java", "-jar", "./app.jar" ]
