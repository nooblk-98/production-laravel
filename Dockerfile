FROM php:7.4-fpm-alpine

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html

RUN apk add --no-cache \
        git \
        unzip \
        zip \
        oniguruma-dev \
        libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring zip

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY application/ /var/www/html/

RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader --no-scripts \
    && mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache || true \
    && chmod -R ug+rwx storage bootstrap/cache || true

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["php-fpm", "-F"]