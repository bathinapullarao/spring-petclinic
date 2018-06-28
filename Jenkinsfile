//import static groovyx.net.http.ContentType.TEXT

def CONTAINER_NAME="jenkins-pipelin"
def CONTAINER_TAG="latest"
def DOCKER_HUB_USER="bathinapullarao"
def HTTP_PORT="8087"
node 
{
	stage('declareEnvVariables')
	{
        def dockerHome = tool 'myDocker'
        def mavenHome  = tool 'myMaven'
        env.PATH = "${dockerHome}/bin:${mavenHome}/bin:${env.PATH}"
        }
	
	stage('gitCheckout') 
	{
        checkout scm
    	}
	
	stage('Build')
	{
        sh "mvn package"
        }
  
     stage("Prune_deleteUnusedImages")

	{
        imagePrune(CONTAINER_NAME)
        }
    stage('buildDockerImage')
	{
        imageBuild(CONTAINER_NAME, CONTAINER_TAG)
        }
    stage('pushtoDockerRegistry')
	{
        withCredentials([usernamePassword(credentialsId: 'dockerHubAccount', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) 
		{
            pushToImage(CONTAINER_NAME, CONTAINER_TAG, USERNAME, PASSWORD)
                }
	}	


    stage('Run App'){
        runApp(CONTAINER_NAME, CONTAINER_TAG, DOCKER_HUB_USER, HTTP_PORT)
    }

	stage('Sonar')
	{
           try {
            sh "mvn sonar:sonar"
            } 
	catch(error)
	    {
            echo "The sonar server could not be reached ${error}"
            }
        }

/*	stage('build & SonarQube Scan') 
	{
    withSonarQubeEnv('http://192.168.91.49:9000') 
		{
      sh 'mvn clean package sonar:sonar'
    		} // SonarQube taskId is automatically attached to the pipeline context
  	}

stage("Quality Gate") 
	{
  timeout(time: 1, unit: 'HOURS') 
		{ // Just in case something goes wrong, pipeline will be killed after a timeout
    def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
    if (qg.status != 'OK') 
			{
      error "Pipeline aborted due to quality gate failure: ${qg.status}"
			}
		}
	}	
	

	
	
	stage('Junit')
	{
        try {
            sh "mvn test" 
	    } catch(error)
	    {
            echo "The Maven can not perform Junit ${error}"
            }
        }
	*/
	
    stage('approvalofQA'){
    input "Deploy to QA?"
    }
    node {
	    slackSend (channel: "#jenkins_notification", color: '#4286f4', message: "Deploy Approval: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.JOB_DISPLAY_URL})")
                script {
                    try  {
                        timeout(time:30, unit:'MINUTES') 
			    {
                            env.APPROVE_QA = input message: 'Deploy to QA', ok: 'Continue',
                                parameters: [choice(name: 'APPROVE_QA', choices: 'YES\nNO', description: 'Deploy to QA environment?')]
                            if (env.APPROVE_QA == 'YES')
				    {
					    
			            stage('deploy to QA')
					    {
                                            dipQA(CONTAINER_NAME, CONTAINER_TAG, DOCKER_HUB_USER, 8086)
                                            }
					    	    
                                env.DPROD = true
                            	    } else 
				    {
                                env.DPROD = false
			        echo "QA test Faild"
                                    }
                            }
                          } catch (error) 
			  {
                        env.DPROD = true
                        echo 'Timeout has been reached! Deploy to QA automatically activated'
                          }
                      }
	  }
    stage('approvalOfUAT'){
    input "Deploy to UAT?"
    }
    node {
	slackSend (channel: "#jenkins_notification", color: '#4286f4', message: "Deploy Approval: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.JOB_DISPLAY_URL})")
                script {
                    try  {
                        timeout(time:30, unit:'MINUTES') 
			    {
                            env.APPROVE_UAT = input message: 'Deploy to UAT', ok: 'Continue',
                                parameters: [choice(name: 'APPROVE_UAT', choices: 'YES\nNO', description: 'Deploy to UAT?')]
                            if (env.APPROVE_UAT == 'YES')
				    {
				    stage('deploy to UAT'){
        			    	dipUAT(CONTAINER_NAME, CONTAINER_TAG, DOCKER_HUB_USER, 8087)
        						}
                                env.DPROD = true
                            	    } else 
				    {
                                env.DPROD = false
			        echo "UAT faild"
                            	    }
                            }
                    	  } catch (error) 
			{
                        env.DPROD = true
                        echo 'Timeout has been reached! Deploy to PRODUCTION automatically activated'
                    	}
		      }
	    
          }
    stage('approvalOfProd'){
    input "Deploy to Prod?"
    }
    node {
	    slackSend (channel: "#jenkins_notification", color: '#4286f4', message: "Deploy Approval: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.JOB_DISPLAY_URL})")
                script {
                    try  {
                        timeout(time:30, unit:'MINUTES') 
			    {
                            env.APPROVE_PROD = input message: 'Deploy to Production', ok: 'Continue',
                                parameters: [choice(name: 'APPROVE_PROD', choices: 'YES\nNO', description: 'Deploy from STAGING to PRODUCTION?')]
                            if (env.APPROVE_PROD == 'YES')
				    {
                                stage('deploy to Prod')
					    {
        				dipProd(CONTAINER_NAME, CONTAINER_TAG, DOCKER_HUB_USER, 8088)
        				    }
					    env.DPROD = true
				    }
			             else 
				    {
                                env.DPROD = false
				echo "Rejected to Deploy by DEVOPS eng"
                            	    }
                             }
                    	   } catch (error) 
			   {
                        env.DPROD = true
                        echo 'Timeout has been reached! Deploy to PRODUCTION automatically activated'
                           }
		       }
    
	    }}	
	



def imagePrune(containerName){
    try {
        sh "docker image prune -f"
        sh "docker stop $containerName"
    } catch(error){}
}

def imageBuild(containerName, tag){
    sh "docker build -t $containerName:$tag  -t $containerName --pull --no-cache ."
    echo "Image build complete"
}

def pushToImage(containerName, tag, dockerUser, dockerPassword){
    sh "docker login -u $dockerUser -p $dockerPassword"
    sh "docker tag $containerName:$tag $dockerUser/$containerName:$tag"
    sh "docker push $dockerUser/$containerName:$tag"
    echo "Image push complete"
}

def runApp(containerName, tag, dockerHubUser, httpPort){
    sh "docker pull $dockerHubUser/$containerName"
 //   sh "docker run -d --rm -p $httpPort:$httpPort --name $containerName $dockerHubUser/$containerName:$tag"
    sh "docker run -p $httpPort:$httpPort --name $containerName $dockerHubUser/$containerName:$tag"   
	echo "Application started on port: ${httpPort} (http)"
}



def dipQA(containerName, tag, dockerHubUser, httpPort){
    sh "docker pull $dockerHubUser/$containerName"
    sh "docker run -p $httpPort:$httpPort --name $containerName $dockerHubUser/$containerName:$tag"
    echo "Application started on port: ${httpPort} (http)"
}
def dipUAT(containerName, tag, dockerHubUser, httpPort){
    sh "docker pull $dockerHubUser/$containerName"
    sh "docker run -p $httpPort:$httpPort --name $containerName $dockerHubUser/$containerName:$tag"
    echo "Application started on port: ${httpPort} (http)"
}
def dipProd(containerName, tag, dockerHubUser, httpPort){
    sh "docker pull $dockerHubUser/$containerName"
    sh "docker run -p $httpPort:$httpPort --name $containerName $dockerHubUser/$containerName:$tag"
    echo "Application started on port: ${httpPort} (http)"
}

