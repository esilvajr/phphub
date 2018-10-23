FROM ubuntu:18.04
MAINTAINER Arquivei

#tzconfig
ARG PHP_TZ="America/Sao_Paulo"
ENV DEBIAN_FRONTEND noninteractive

RUN echo $PHP_TZ > /etc/timezone \
    && export LC_ALL=en_US.UTF-8 \
    && export LANG=en_US.UTF-8 \
    && export LANGUAGE=en_US.UTF-8

#installing ubuntu common packages
RUN apt-get update \
    && apt-get -y --no-install-recommends install ca-certificates tzdata vim wget gcc build-essential libxml2-dev libssl-dev libcurl4-openssl-dev pkg-config curl make libpq-dev libpspell-dev librecode-dev libcurl4-openssl-dev libxft-dev

RUN dpkg-reconfigure tzdata

#installing php wirh php-fpm and cli
RUN wget https://secure.php.net/distributions/php-7.2.11.tar.gz --no-check-certificate \
    && tar zxvf php-7.2.11.tar.gz && cd php-7.2.11 \
    && ./configure --prefix=/etc/php/7.2 \
        --with-config-file-scan-dir=/etc/php/7.2/php-fpm/conf.d/ \
        --bindir=/usr/bin \
        --sbindir=/usr/sbin \
        --enable-fpm \
        --enable-cli \
        --enable-debug \
        --enable-soap \
        --enable-zip \
        --enable-mbstring \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
        --with-mysqli \
        --with-pgsql \
        --with-pdo-mysql \
        --with-pdo-pgsql \
        --with-curl \
        --with-openssl \
        --with-zlib \
    && make && make install \
    && cp php.ini-production /etc/php/7.2/lib/php.ini \
    && rm -rf /application/php-7.2*

RUN cp /etc/php/7.2/etc/php-fpm.conf.default /etc/php/7.2/etc/php-fpm.conf

#installing redis
RUN apt-get update \
    && apt-get -y install autoconf \
    && printf "\n" | pecl install redis

RUN mkdir /etc/php/7.2/php-fpm \
    && mkdir /etc/php/7.2/php-fpm/conf.d \
    && echo "extension=redis.so" > /etc/php/7.2/php-fpm/conf.d/redis.ini

#configuring php-fpm
COPY php-fpm/php-fpm-base.conf /etc/php/7.2/etc/php-fpm.d/z-overrides.conf
COPY php-fpm/entrypoint.sh /entrypoint

ENTRYPOINT /entrypoint
