FROM node:14.17.1-alpine AS base
WORKDIR /blog
COPY . .
RUN npm config set strict-ssl false
RUN npm install hexo --registry=https://registry.npm.taobao.org
RUN ./node_modules/hexo/bin/hexo g

FROM alpine AS upload
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add git
COPY --from=base /blog /blog
WORKDIR /blog
RUN date > buildtime
RUN git add . && git commit -m "auto commit by docker build" && git push

FROM nginx:alpine
COPY --from=upload /blog/public /usr/share/nginx/html
COPY ads.txt /usr/share/nginx/html
