FROM node AS base
WORKDIR /blog
COPY . .
RUN npm config set strict-ssl false
RUN npm install hexo --registry=https://registry.npm.taobao.org
RUN ./node_modules/hexo/bin/hexo g

FROM alpine:3.18.4 AS upload
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add git
COPY --from=base /blog /blog
WORKDIR /blog
RUN date > buildtime
RUN git add . && git commit -m "auto commit by docker build" && git push

FROM blog:base
RUN rm -fr /usr/share/nginx/html
COPY --from=upload /blog/public /usr/share/nginx/html
COPY ads.txt /usr/share/nginx/html
