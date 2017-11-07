FROM php:5.6-apache

RUN apt-get update && apt-get install --no-install-recommends  -y \
    mysql-client \
    imagemagick \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libpng12-dev \
    libjpeg-dev \
    libicu-dev \
    libbz2-dev \
    libxslt-dev \
    libldap2-dev \
    zlib1g-dev \
    mcrypt \
    unzip \
    wget

#PHP Extensions
RUN pecl install xdebug && docker-php-ext-enable xdebug \
  && printf "\n" | pecl install imagick && docker-php-ext-enable imagick \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mbstring zip bcmath intl exif fileinfo \
  && docker-php-ext-enable opcache

#Set the timezone.
RUN echo "Europe/Warsaw" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

#XDEBUG
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini

RUN echo "max_execution_time = 360" >> /usr/local/etc/php/php.ini
RUN echo "memory_limit=-1" >> /usr/local/etc/php/php.ini

#MEMCACHEED
RUN apt-get update && apt-get install -y libmemcached11 libmemcachedutil2 build-essential libmemcached-dev libz-dev
RUN pecl install memcached-2.2.0
RUN echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

#DRUSH
RUN wget https://s3.amazonaws.com/files.drush.org/drush.phar -O /usr/bin/drush && chmod +x /usr/bin/drush && drush init -y

RUN a2enmod rewrite

#COMPOSER
#RUN wget https://getcomposer.org/download/1.4.1/composer.phar -O /usr/bin/composer && chmod +x /usr/bin/composer
#RUN mkdir /composer

#VIM
RUN apt-get install -y vim
#NET-TOOLS
RUN apt-get install -y net-tools

RUN apt-get clean && rm -rf /vsar/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/www/html/cache/kernel/library