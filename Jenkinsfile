// Local Parameters
def remote = [:]
def DATE_TIME
def AMI_NAME
def PACKER_FILE
// set default adjoin_flag value
// def adjoin_flag = (params.ADJOIN_FLAG) ? 1 : 0


// Pipeline
pipeline {


  // Incoming Parameters
  parameters {
    credentials credentialType: 'com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl', defaultValue: 'rtxcloud-d32d1-dtcp01', name: 'AWS_CREDS', required: true
    credentials credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl', defaultValue: 'ae615a3f-017f-499e-bb76-3792f95e988f', name: 'GITHUB_CREDS', required: false
    string(name: 'BUILD_NODE', defaultValue: 'prc-builder.twk.us.ray.com')
    string(name: 'Packer_GIT_BRANCH', defaultValue: 'development')
  }


  // Build Agent(s)
  agent {
    label "$BUILD_NODE"
  }


  environment
  {
    DATE_TIME   = sh(returnStdout: true, script: "date +%Y%m%d-%H%M%S").trim()
    //AMI_NAME    = "PCS_RHEL_8_Base_${env.DATE_TIME}"
    //PACKER_FILE = "./linux_base_image.json"

    // Required for operations that need the proxy
    http_proxy  = 'http://proxy.ext.ray.com:80'
    HTTP_PROXY  = 'http://proxy.ext.ray.com:80'
    https_proxy = 'http://proxy.ext.ray.com:80'
    HTTPS_PROXY = 'http://proxy.ext.ray.com:80'
    no_proxy    = '.us-gov-west-1.compute.internal, 127.0.0.1, localhost, .ray.com, s3-us-gov-west-1.amazonaws.com, 169.254.169.254, rds.amazonaws.com, s3-fips-us-gov-west-1.amazonaws.com'
    NO_PROXY    = '.us-gov-west-1.compute.internal, 127.0.0.1, localhost, .ray.com, s3-us-gov-west-1.amazonaws.com, 169.254.169.254, rds.amazonaws.com, s3-fips-us-gov-west-1.amazonaws.com'
     }


  // Pipeline Stages
  stages {

    // Prepare Workspace
    stage('Prepare Workspace') {
      steps {

        sh('set +x; echo "========== Prepare Workspace =========="')

        // Clean workspace
        deleteDir()

        // Get source from Git repository
        checkout scm
        withCredentials([usernamePassword(credentialsId: "$GITHUB_CREDS", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
        sh('git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.ids.ray.com/nrp0257371/jenkins.git')
        }

        // Print Environment Varables; Uncomment for - DEBUGGING INFORMATION
        sh('printenv')

      }
    }  // end Prepare Workspace
     
   
    // AWS Auth
    stage('AWS Auth') {
       steps  {
           withCredentials([usernamePassword(credentialsId: "$AWS_CREDS", passwordVariable: 'AWS_SECRET_ACCESS_KEY ', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        sh('aws s3 ls')     
        }
       }
    }
    
 
   // end AWS Validate
   
   // AWS Validate
    stage('AWS Validate') {
      steps{

        sh('set +x; echo "========== AWS Validate  =========="')
        
    
          //sh('pwd; ls -al')  //Uncomment for - DEBUGGING INFORMATION
          //sh('aws s3api list-buckets --query "Buckets[].Name" ') 
       }
    }  // end AWS Validate
    
   stage("AWS check") {
    steps{
     sh('set +x; echo "========== AWS Check  =========="')
 //   credentials credentialType: 'com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl', defaultValue: 'rtxcloud-d32d1-dtcp01', name: 'AWS_CREDS', required: true {AWS("--region=us-gov-west-1 s3api list-buckets ")}
    }
   }
  }
}
