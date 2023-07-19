#!/bin/sh
version=${1}

workDir="/home/blog/13/"

projectName="blog"

dockerfileDir="/server/"${projectName}"/"
dockerFile=${dockerfileDir}Dockerfile

dockerContainerPort="40000"
dockerContainerName="blog-"${dockerContainerPort}

timeStr=`date +%Y%m%d`
imageVersion=${timeStr}_${version}

alias sdocker="sudo docker"

# update from gitee
cd ${workDir}
git pull gitee master

# copy file
cd ${dockerfileDir}
rm -fr *
rm -fr .git .github 
cp -pr ${workDir}* ${dockerfileDir}
cp -pr ${workDir}.git ${dockerfileDir}


# docker build 
sdocker build . -t ${projectName}:${imageVersion} 

# docker deploy
sdocker rm -f ${dockerContainerName}
sdocker run -d --name ${dockerContainerName} -p ${dockerContainerPort}:80 --restart=always ${projectName}:${imageVersion}

# update git to origin
sleep 10
cd ${workDir}
git pull gitee master
git add .
git commit -m 'auto commit by docker build' 
git push origin master 
