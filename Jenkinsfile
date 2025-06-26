pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TF_VAR_app_name       = "ecommerce-${env.BRANCH_NAME == 'main' ? 'prod' : 'dev'}"
        TF_VAR_environment    = "${env.BRANCH_NAME == 'main' ? 'prod' : 'dev'}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init -backend-config="backend.hcl"'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                    archiveArtifacts artifacts: 'terraform/tfplan', onlyIfSuccessful: true
                }
            }
        }
        
        stage('Approval') {
            when {
                branch 'main'
            }
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: '¿Aplicar cambios en producción?', ok: 'Confirmar'
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        
        stage('Destroy Dev Environment') {
            when {
                not { branch 'main' }
                beforeAgent true
            }
            steps {
                dir('terraform') {
                    sh 'terraform destroy -auto-approve -var-file=dev.tfvars'
                }
            }
        }
    }
    
    post {
        success {
            slackSend(
                channel: '#aws-deployments',
                message: "✅ Despliegue exitoso: ${env.JOB_NAME} (${env.BRANCH_NAME}) - ${env.BUILD_URL}"
            )
        }
        failure {
            slackSend(
                channel: '#aws-alerts',
                message: "❌ Fallo en despliegue: ${env.JOB_NAME} (${env.BRANCH_NAME}) - ${env.BUILD_URL}"
            )
        }
        always {
            cleanWs()
        }
    }
}