ARG php_version
FROM "php:${php_version}-fpm"

ARG php_version

# Configure application home directory
ENV HOME /app-home
RUN mkdir -p $HOME && chmod 777 $HOME

# Install all required components
RUN apt update && apt -y install \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    libmcrypt-dev \
    libwebp-dev \
    libicu-dev \
    wget \
    openssl \
    git \
    openssh-client \
    mariadb-client \
    build-essential \
    autoconf \
    automake \
    nasm \
    bc \
    unzip \
    dnsutils

# Configure PHP GD extension to support JPEG, FreeType and WebP.
# The configuration switches was changed prior to PHP 7.4 version.
RUN if [ `echo "($php_version < 7.4)" | bc` -eq "1" ]; then docker-php-ext-configure gd --with-jpeg-dir --with-freetype-dir --with-webp-dir; else docker-php-ext-configure gd --with-jpeg --with-freetype --with-webp; fi

RUN docker-php-ext-install -j$(nproc) \
    gd \
    soap \
    bcmath \
    intl \
    pdo_mysql \
    simplexml \
    xsl \
    zip

# PHP mcrypt extension installation is only possible with `pecl` since 7.2
RUN if [ `echo "($php_version < 7.2)" | bc` -eq 1 ]; then \
        docker-php-ext-install -j$(nproc) mcrypt; \
    fi

RUN if [ `echo "($php_version >= 7.2)" | bc` -eq 1 ]; then \
        pecl channel-update pecl.php.net; \
        pecl install mcrypt; \
        echo "extension=mcrypt.so" > /usr/local/etc/php/conf.d/mcrypt.ini; \
    fi

# Install and configure XDebug
# Configuration is dynamically generated in entrypoint
RUN if [ `echo "($php_version == 5.6)" | bc` -eq 1 ]; then \
        pecl install xdebug-2.5.5; \
    elif [ `echo "($php_version == 7.0)" | bc` -eq 1 ]; then \
        pecl install xdebug-2.8.1; \
    elif [ `echo "($php_version >= 7.1)" | bc` -eq 1 ]; then \
        pecl install xdebug-2.9.2; \
    fi

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer

# Configure PHP
RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN echo 'memory_limit=-1' > /usr/local/etc/php/php-cli.ini
ADD www.conf /usr/local/etc/php-fpm.d/www.conf

# Install NodeJS
ENV NODE_RELEASE v12.16.1
RUN wget https://nodejs.org/download/release/${NODE_RELEASE}/node-${NODE_RELEASE}-linux-x64.tar.gz -O nodejs.tar.gz && \
    tar -xf nodejs.tar.gz && \
    rm nodejs.tar.gz && \
    mv node-${NODE_RELEASE}* /opt/node && \
    ln -s /opt/node/bin/node /usr/local/bin/node && \
    ln -s /opt/node/bin/npm /usr/local/bin/npm

# Install MSMTP to enable PHP mail() function
RUN apt update && apt -y install msmtp msmtp-mta ca-certificates
RUN echo "[mail function]" >> /usr/local/etc/php/conf.d/mail.ini
RUN echo "sendmail_path = /usr/bin/msmtp -C /app-home/.msmtprc -t" >> /usr/local/etc/php/conf.d/mail.ini

# General image configuration
WORKDIR /app
ENV ENTRYPOINT_FILE /usr/local/bin/magento-entrypoint
ADD entrypoint ${ENTRYPOINT_FILE}
RUN chmod 0755 ${ENTRYPOINT_FILE}

ENTRYPOINT ["sh", "/usr/local/bin/magento-entrypoint"]
CMD ["php-fpm", "-c", "/app-home/.php/fpm"]
