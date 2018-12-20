#!groovy
def DOCKER_HUB_USER="bathinapullarao"

pipeline 
{
  agent any
    stages 
    {
       stage('Maven Install') 
       {
          steps 
          {
          sh 'mvn clean install'
          }
       }
      stage('Docker Build') 
       {
         steps 
         {
          sh 'docker build -t bathinapullarao/spring-petclinic:latest .'
         }
       }
      stage('Docker Push') 
      {
        steps 
        {
         withCredentials([usernamePassword(credentialsId: 'dockerHubAccount', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) 
          {
            sh "docker login -u $env.USERNAME -p $env.PASSWORD"
            sh "docker push bathinapullarao/spring-petclinic:latest"
            echo "Image push complete"
          }
        }
      }
   }
}
