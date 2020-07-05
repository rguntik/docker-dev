FROM php:7.4-fpm

MAINTAINER Roman Huntik <rguntik@gmail.com>

ARG environment=production

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    zip \
    unzip \
    libxml2-dev \
    procps\
    cron\
    libpq-dev \
    libmcrypt-dev \
    postgresql-client \
    && apt-get autoremove -y -f \
    && apt-get clean -y

# Install php extensions
RUN docker-php-ext-install -j$(nproc) \
    pdo \
    mysqli \
    opcache \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    intl \
    soap \
    bcmath \
    pcntl

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER 1 \
    COMPOSER_HOME /composer \
    PATH=$COMPOSER_HOME/vendor/bin:$PATH

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN if [ "$environment" = "development" ] ; then \
    pecl install xdebug && docker-php-ext-enable xdebug \
    ; fi


ADD php.ini /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html

CMD ["php-fpm"]

EXPOSE 9000
