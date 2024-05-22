SHELL:=bash
DATE := $(shell date +"%s")

all: pull build update

pull:
	git pull

build:
	docker build . -t blog:v${DATE} 

update:
	cd /data/docker-compose/blog && sed -i "s/image:\ blog:.*/image:\ blog:v${DATE}/g"  docker-compose.yaml && docker-compose down && docker-compose up -d
clean:
	
