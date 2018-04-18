# docker-sonarqube
For build a SonarQube docker image

# Supported tags and respective Dockerfile links
7.1, latest (7.0/Dockerfile)

# Quick reference
* Where to get help:
the Docker Community Forums, the Docker Community Slack, or Stack Overflow

* Where to file issues:

   https://github.com/SonarSource/docker-sonarqube/issues

* Maintained by:

  [SonarSource](https://github.com/SonarSource/docker-sonarqube)

# How to use this image
## Run SonarQube
The server is started this way:


```
$ docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 jermine/sonarqube
```

By default you can login as admin with password admin, see authentication.

To analyse a project:


```
$ On Linux:
mvn sonar:sonar
```



```
$ With boot2docker:
mvn sonar:sonar -Dsonar.host.url=http://$(boot2docker ip):9000 -Dsonar.jdbc.url="jdbc:h2:tcp://$(boot2docker ip)/sonar"
```

## Database configuration
By default, the image will use an embedded H2 database that is not suited for production.

The production database is configured with these variables: `SONARQUBE_JDBC_USERNAME`, `SONARQUBE_JDBC_PASSWORD` and `SONARQUBE_JDBC_URL`.


```
$ docker run -d --name sonarqube \
    -p 9000:9000 -p 9092:9092 \
    -e SONARQUBE_JDBC_USERNAME=sonar \
    -e SONARQUBE_JDBC_PASSWORD=sonar \
    -e SONARQUBE_JDBC_URL=jdbc:postgresql://localhost/sonar \
    jermine/sonarqube
```

# Run SonarQube with a PostgreSQL database

## Requirements

 * Docker Engine 1.9
 * Docker Compose 1.6

## Compose file

Create this `docker-compose.yml` file:

```yaml
version: "2"

services:
  sonarqube:
    image: jermine/sonarqube
    ports:
      - "9000:9000"
    networks:
      - sonarnet
    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
    volumes:
      - sonarqube_conf:/opt/sonarqube/conf
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_bundled-plugins:/opt/sonarqube/lib/bundled-plugins

  db:
    image: postgres
    networks:
      - sonarnet
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
    volumes:
      - postgresql:/var/lib/postgresql
      # This needs explicit mapping due to https://github.com/docker-library/postgres/blob/4e48e3228a30763913ece952c611e5e9b95c8759/Dockerfile.template#L52
      - postgresql_data:/var/lib/postgresql/data

networks:
  sonarnet:
    driver: bridge

volumes:
  sonarqube_conf:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_bundled-plugins:
  postgresql:
  postgresql_data:
```

Use [docker-compose](https://github.com/docker/compose) to start the containers.

```bash
$ docker-compose up
```

Restart the containers (after plugin upgrade or install for example).

```bash
$ docker-compose restart sonarqube
```

Analyse a project:

```bash
mvn sonar:sonar \
  -Dsonar.host.url=http://$(boot2docker ip):9000 \
  -Dsonar.jdbc.url=jdbc:postgresql://$(boot2docker ip)/sonar
```