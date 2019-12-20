ARG php_version
FROM "php:${php_version}-fpm-alpine"

ARG php_version

# Install all required components
RUN apk add \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    libmcrypt-dev \
    icu-dev \
    composer \
    wget \
    openssl \
    git \
    openssh-client \
    mysql-client \
    bash

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) \
    iconv \
    gd \
    soap \
    bcmath \
    ctype \
    dom \
    hash \
    intl \
    mbstring \
    pdo_mysql \
    simplexml \
    xsl \
    zip

# Using PHP prior to version 7.2 requires installing mcrypt extension
RUN [ `echo "($php_version < 7.2)" | bc` == "1" ] && docker-php-ext-install -j$(nproc) mcrypt || true

# Configure entrypoint related stuff
ENV COMPOSER_HOME /composer_home
RUN mkdir /composer_home
RUN chmod 777 /composer_home
WORKDIR /app

ENV HOME /home/user
RUN mkdir $HOME && chmod 777 $HOME

ENV ENTRYPOINT_FILE /usr/local/bin/magento-entrypoint
ADD entrypoint ${ENTRYPOINT_FILE}
RUN chmod +x $ENTRYPOINT_FILE

ENTRYPOINT ["sh", "/usr/local/bin/magento-entrypoint"]
CMD ["php-fpm"]
