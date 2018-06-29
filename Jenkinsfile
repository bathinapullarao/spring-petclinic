#!groovy

def CONTAINER_NAME="spring-petclinic"
def CONTAINER_TAG="latest"
def DOCKER_HUB_USER="bathinapullarao"
def HTTP_PORT="8087"


pipeline 
{
  agent none
  stages 
  {
    stage('Maven Install') 
    {
      agent 
      {
        docker 
        {
          image 'maven:3.5.0'
        }
      }
      steps 
      {
        sh 'mvn clean install'
      }
    }
    stage('Docker Build') 
    {
      agent any
      steps 
      {
        sh 'docker build -t bathinapullarao/spring-petclinic:latest .'
        // 'docker build -t shanem/spring-petclinic:latest .'
      }
    }
    stage('Docker Push') 
    {
      agent any
      steps 
      {
        stage('pushtoDockerRegistry')
        {
        withCredentials([usernamePassword(credentialsId: 'dockerHubAccount', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) 
          {
            pushToImage(CONTAINER_NAME, CONTAINER_TAG, USERNAME, PASSWORD)
          }
        }	
        
      }
    }
  }
}
def pushToImage(containerName, tag, dockerUser, dockerPassword)
{
    sh "docker login -u $dockerUser -p $dockerPassword"
    sh "docker tag $containerName:$tag $dockerUser/$containerName:$tag"
    sh "docker push $dockerUser/$containerName:$tag"
    echo "Image push complete"
}
