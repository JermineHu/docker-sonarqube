FROM openjdk:8-jre-alpine
MAINTAINER Jermine <Jermine.hu@qq.com>
ENV SONAR_VERSION=7.4 \
    SONARQUBE_HOME=/opt/sonarqube \
    # Database configuration
    # Defaults to using H2
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=
# Http port
EXPOSE 9000
RUN addgroup -S sonarqube && adduser -S -G sonarqube sonarqube
RUN set -x \
    && apk add --no-cache bash su-exec \
    && apk add --no-cache --virtual .build-deps gnupg unzip libressl wget \
    && mkdir /opt \
    && cd /opt \
    && wget -O sonarqube.zip --no-verbose https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && unzip sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && chown -R sonarqube:sonarqube sonarqube \
    && apk del .build-deps \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

VOLUME "$SONARQUBE_HOME/data"
WORKDIR $SONARQUBE_HOME
COPY run.sh $SONARQUBE_HOME/bin/
ENTRYPOINT ["./bin/run.sh"]
