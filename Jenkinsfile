pipeline {
  agent any
  
  environment {
        TF_IN_AUTOMATION = "true"
        KUBECONFIG = "${HOME}/.kube/config"
    }

  stages {

    stage('Load Images into Minikube') {
      steps {
        sh 'minikube image load ibrahim372/fr:latest'
        sh 'minikube image load ibrahim372/bk:latest'
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

