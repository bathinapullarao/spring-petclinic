FROM openjdk:8-jdk-alpine
LABEL maintainer="Bathina Pullarao"
COPY /target/spring-petclinic-2.0.0.BUILD-SNAPSHOT.jar /var/lib/spring-petclinic-2.0.0.BUILD-SNAPSHOT.jar
CMD ["java","-jar","/var/lib/spring-petclinic-2.0.0.BUILD-SNAPSHOT.jar"]
