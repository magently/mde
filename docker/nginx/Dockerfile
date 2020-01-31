FROM alpine

RUN apk add --no-cache nginx nginx-mod-http-perl perl openssl

RUN rm /etc/nginx/conf.d/default.conf
ADD nginx.conf /etc/nginx/nginx.conf
ADD magento1.conf /etc/nginx/magento1.conf
ADD magento2.conf /etc/nginx/magento2.conf
ADD proxy.conf /etc/nginx/conf.d/proxy.conf

ADD entrypoint /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
