SHELL:=bash
DATE := $(shell date +"%s")

all: pull build update clean

pull:
	git pull

build:
	docker build --memory=500m . -t blog:v${DATE} 

update:
	cd /data/docker-compose/blog && sed -i "s/image:\ blog:.*/image:\ blog:v${DATE}/g"  docker-compose.yaml && docker-compose down && docker-compose up -d
clean:
	docker images|grep blog|grep -v ${DATE} | while read name ; do docker rmi `echo $${name}|awk '{print $$3}'` ; done	
