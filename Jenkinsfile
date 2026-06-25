pipeline {
    agent { label 'gpu-agent-2' }
    parameters {
        string(
            name: 'IMAGE_NAME',
            defaultValue: 'nitibench', 
        )
        string(
            name: 'IMAGE_TAG',
            defaultValue: 'test',
        )
        string(
            name: 'CONTAINER_NAME',
            defaultValue: 'nitibench-container',
        )
        string(
            name: 'CONFIG_PATH',
            defaultValue: '/app/LRG/config/all_e2e_config/lclm.yaml',
        )
    }
    environment {
        HTTP_PROXY = 'http://10.0.0.3:3128'
        HTTPS_PROXY = 'http://10.0.0.3:3128'
        NO_PROXY = 'localhost,127.0.0.1,metadata.google.internal'
        IMAGE_NAME = "${params.IMAGE_NAME}"
        IMAGE_TAG = "${params.IMAGE_TAG}"
        CONTAINER_NAME = "${params.CONTAINER_NAME}"
        CONFIG_PATH = "${params.CONFIG_PATH}"
    }

    stages {
        stage('Prepare LightRAG Server & Proxy') {
            steps {
                sh '''
                make clean \
                '''
            }
        }
        stage('Start Container & Run Script') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'API_KEY',
                        variable: 'GEMINI_API_KEY'
                    ),
                    string(
                        credentialsId: 'HF_TOKEN',
                        variable: 'HF_TOKEN'
                    )
                ]) {
                    script {
                        sh """
                        make build run exec \
                            HF_TOKEN='${HF_TOKEN}' \
                            GEMINI_API_KEY='${GEMINI_API_KEY}'
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            sh '''
            make stop
            echo "Success"
            '''
        }
        unsuccessful {
            sh '''
            make stop
            echo "Unsuccessful"
            '''
        }
    }
}