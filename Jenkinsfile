#!groovy

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
       }
    }
    stage('Docker Push') 
    {
      agent any
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
