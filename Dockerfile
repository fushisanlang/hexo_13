FROM node:14.17.1-alpine AS base
WORKDIR /blog
COPY . .
RUN npm install hexo --registry=https://registry.npm.taobao.org
RUN ./node_modules/hexo/bin/hexo g

FROM alpine AS upload
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add git
COPY --from=base /blog /blog
WORKDIR /blog
RUN git pull gitee master
RUN git add . 
RUN git config --global user.email 313346216@qq.com 
RUN git config --global user.name fushisanlang 
RUN git commit -m 'auto commit by docker build' 
RUN git push gitee master


FROM nginx:alpine
COPY --from=upload /blog/public /usr/share/nginx/html
