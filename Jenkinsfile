pipeline {
  agent any
  
  environment {
        TF_IN_AUTOMATION = "true"
        KUBECONFIG = "${HOME}/.kube/config"
    }

  stages {

    stage('Cloner le dépôt') {
            steps {
                 checkout scm
            }
        }
    
  stage('Pull Docker Image') {
      steps {
        script {
          sh 'docker pull ibrahim372/bk:latest'
          sh 'docker pull ibrahima372/fr:latest'
        }
      }
    }
    

    stage('Deploy with Terraform') {
      steps {
        dir('terraform') {
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }
  }
}

