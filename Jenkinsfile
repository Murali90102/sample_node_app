pipeline {
    agent any	
    environment {	
        IMAGE_NAME = "sample_node_app"
        TAG = "${BUILD_ID}"
        REPO = "murali90102"
	} 
    stages {
        stage('SCM Checkout') {
            steps {
                cleanWs()
                //git branch: 'main', url: 'https://github.com/Murali90102/sample_node_app.git'

                // checkout scmGit(branches: [[name: '*/main']], extensions: [[$class: 'UserExclusion', excludedUsers: 'jenkins_build_user']], userRemoteConfigs: [[credentialsId: 'githubCreds', url: 'https://github.com/Murali90102/sample_node_app.git']])
            
                checkout scmGit(branches: [[name: '*/main']], extensions: [[$class: 'UserExclusion', excludedUsers: 'jenkins_build_user'], [$class: 'PathRestriction', excludedRegions: 'Jenkinsfile', includedRegions: '']], userRemoteConfigs: [[credentialsId: 'githubCreds', url: 'https://github.com/Murali90102/sample_node_app.git']])
            }
		}
        stage("Docker build"){
            steps {
				sh 'docker version'
				sh "docker build -t ${REPO}/${IMAGE_NAME}:${TAG} ."
				sh 'docker ps'
            }
        }
        stage('DockerHub_login') {

			steps {
                withCredentials([usernamePassword(credentialsId: 'dockerHubCreds', passwordVariable: 'dockerHubPwd', usernameVariable: 'dockerHubUsername')]) {
                    sh 'echo $dockerHubPwd | docker login -u $dockerHubUsername --password-stdin'
                }
			}
		}
        stage('Push2DockerHub') {
			steps {
				sh "docker push ${REPO}/${IMAGE_NAME}:${TAG}"
                sh "sed -i \"s#${REPO}/${IMAGE_NAME}:.*#${REPO}/${IMAGE_NAME}:${TAG}#1\" docker-compose.yaml"

                sh 'git config --local user.email "muralikrishna.appari@outlook.com"'
                // sh 'git config --local user.name "murali90102"'
                sh 'git config --local user.name "jenkins_build_user"'
                
                sh "git status"

                withCredentials([usernamePassword(credentialsId: 'githubCreds', passwordVariable: 'ghPassword', usernameVariable: 'ghUsername')]) {
                    sh "git remote set-url origin https://${ghUsername}:${ghPassword}@github.com/Murali90102/sample_node_app.git"
                    
                }

                
                sh "git add docker-compose.yaml"
                sh "git commit -m 'Updated docker-compose.yaml from CI'"
                sh 'git push origin HEAD:main'
			}
		}
		stage('Deploy to VM') {
            steps {
		        script {
                    sshPublisher(publishers: [sshPublisherDesc(configName: 'vm', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'ls -lrt && sudo docker compose up -d', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '.', remoteDirectorySDF: false, removePrefix: '', sourceFiles: 'docker-compose.yaml')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
                }
            }
	    }
    }
    // post {
    //     success{emailext body: '$JOB_NAME is success', subject: '$JOB_NAME is success', to: 'murali.appari@outlook.com'}
    //     failure{emailext body: '$JOB_NAME is failure', subject: '$JOB_NAME is failure', to: 'murali.appari@outlook.com'}
    // }
}