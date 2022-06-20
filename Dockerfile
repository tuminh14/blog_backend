ARG BUILD_IMG=gradle
ARG BUILD_IMG_TAG=3.5-jre8-alpine

# Cache the dependencies
FROM $BUILD_IMG:$BUILD_IMG_TAG AS cache-dependencies
USER root
WORKDIR /tmp/build
COPY . ./
RUN gradle resolveAllDependencies --no-daemon --stacktrace && cd .. && rm -r build

# Build artifact
FROM cache-dependencies AS build
WORKDIR /tmp/build
COPY . .
RUN gradle assemble --no-daemon

# Copy build artifact to destination
FROM openjdk:8-jre-alpine as blog_backend
ARG USERNAME=blog_backend
ARG GROUPNAME=blog_backend
ARG UID=1000
ARG GID=1000
LABEL org.opencontainers.image.authors="duongtrantuminh14@gmail.com"
EXPOSE 80/tcp
EXPOSE 443/tcp
COPY --from=build /tmp/build/build/libs/blog_backend*.war blog_backend.war
COPY grails-app/conf/*yml config/
RUN chmod +x blog_backend.war

# Entrypoint
RUN addgroup --gid $GID $GROUPNAME && adduser --ingroup $GROUPNAME --uid $UID --disabled-password $USERNAME
USER blog_backend
ENTRYPOINT ["java", "-jar", "./blog_backend.war", "-Dspring.config.location=./config/"]
