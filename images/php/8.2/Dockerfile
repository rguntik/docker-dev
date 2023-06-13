FROM php:8.2-fpm

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
    vim \
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

#symfony
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt install symfony-cli

# node
RUN apt-get install -y gnupg2
RUN rm -rf /var/lib/apt/lists/ && curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install nodejs -y

# Installing Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

ADD php.ini /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html

CMD ["php-fpm"]

EXPOSE 9000
