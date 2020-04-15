FROM php:7.3-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Making man pages folders
RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man${i}"; done

# Install dependencies postgresql-dev
RUN apt-get update && apt-get install -y apt-utils \
    build-essential libpq-dev libpng-dev postgresql-client libjpeg62-turbo-dev \
    libfreetype6-dev locales libzip-dev zip jpegoptim optipng pngquant gifsicle \
    vim unzip git curl nodejs

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install php extensions
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && docker-php-ext-install pgsql pdo_pgsql
RUN docker-php-ext-install mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]