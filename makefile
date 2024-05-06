SHELL:=bash
DATE := $(shell date +"%Y%m%d")
pull:
	git pull

build:
	docker build . -t blog:${DATE}_v$(shell docker images|grep blog|grep ${DATE_VER} | wc -l)

update:
	cd /data/docker-compose/blog && sed "s/image:\  blog:.*/image:\  blog:${DATE}_v$(shell docker images|grep blog|grep ${DATE_VER} | wc -l)/g"  docker-compose.yaml && docker-compose down && docker-compose up -d
clean:

all: pull build update