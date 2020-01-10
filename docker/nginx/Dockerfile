FROM nginx:mainline-alpine

RUN apk add --no-cache openssl

RUN rm /etc/nginx/conf.d/default.conf
ADD nginx.conf /etc/nginx/nginx.conf
ADD magento.conf /etc/nginx/conf.d/magento.conf
ADD proxy_magento.conf /etc/nginx/proxy_magento.conf
ADD proxy_varnish.conf /etc/nginx/proxy_varnish.conf

ADD entrypoint /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
