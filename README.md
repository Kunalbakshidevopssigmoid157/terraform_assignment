# terraform_assignment

Jenkins Pineline

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
                script {
                    sh "terraform init"
                    sh "terraform plan"
                    sh "terraform apply --auto-approve"
                   def action = "${params.reply}"
                   if (${action} == "yes") {
                     sh "terraform destroy --auto-approve"
                    }
                }
                
                  
            }
        }
    }
}
}



