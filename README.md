# terraform_assignment

Jenkins Pineline

pipeline {
    agent any
   

    stages {
        stage('git connection') {
            steps {
                // Git hub credentials with git repesitory
            }
        }
        stage('terraform'){
            steps{
             //AWS Credentials{
               
                    sh "terraform init"
                    sh "terraform plan"
                    sh "terraform apply --auto-approve"
                   
                
                
                  
            }
        }
    }
}
}
