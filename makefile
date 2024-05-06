SHELL:=bash
DATE_VER := $(shell date +"%Y%m%d")

update_from_git:
	git pull

build:
	docker build . -t blog:${DATE_VER}_v$(shell docker images|grep blog|grep 20240427 | wc -l)