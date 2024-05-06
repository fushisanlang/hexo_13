SHELL:=bash
DATE := $(shell date +"%Y%m%d")
VERSION := $(shell docker images|grep blog|grep ${DATE_VER} | wc -l)
pull:
	git pull

build:
	docker build . -t blog:${DATE}_v${VERSION}

update:
	cd /data/docker-compose/blog
	sed "s/image:\  blog:.*/image:\  blog:${DATE}_v${VERSION}/g"  docker-compose.yaml
	docker-compose down
	docker-compose up -d

.DEFAULT_GOAL: pull build update