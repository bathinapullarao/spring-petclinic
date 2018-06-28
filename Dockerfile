# Start with a base image containing Java runtime
FROM openjdk:8-jdk-alpine

# Add Maintainer Info
LABEL maintainer="Bathina Pullarao"

# Add a volume pointing to /tmp
VOLUME /tmp

# Make port 8085 available to the world outside this container
EXPOSE 8085

# The application's jar file
COPY /target/spring-petclinic-2.0.0.BUILD-SNAPSHOT.jar //
# The application properties
#COPY /var/lib/jenkins/workspace/Test/src/main/resources/application.yml //
RUN chmod +x /var/lib/jenkins/workspace/op/target/spring-petclinic-2.0.0.BUILD-SNAPSHOT.jar

# Run the jar file
#ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/spring-petclinic-2.0.0.BUILD-SNAPSHOT.jar"]
CMD ["java","-jar","/var/lib/jenkins/workspace/op/target/spring-petclinic-2.0.0.BUILD-SNAPSHOT.jar"]
