FROM alpine

RUN apk add --no-cache nginx openssl
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN rm -f /etc/nginx/conf.d/default.conf
RUN mkdir -p /etc/nginx/conf.d/
ADD nginx.conf /etc/nginx/nginx.conf
RUN mkdir /etc/nginx/templates
ADD magento1.tmpl /etc/nginx/templates/magento1.tmpl
ADD magento2.tmpl /etc/nginx/templates/magento2.tmpl
ADD proxy.tmpl etc/nginx/templates/proxy.tmpl

ADD entrypoint /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
