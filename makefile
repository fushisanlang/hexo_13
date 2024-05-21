SHELL:=bash
DATE := $(shell date +"%Y%m%d")

all: pull build update

pull:
	git pull

build:
	docker build . -t blog:${DATE}_v$(shell docker images|grep blog|grep ${DATE} | wc -l)

update:
	cd /data/docker-compose/blog && sed -i "s/image:\  blog:.*/image:\  blog:${DATE}_v$(shell docker images|grep blog|grep ${DATE} | wc -l)/g"  docker-compose.yaml && docker-compose down && docker-compose up -d
clean:

