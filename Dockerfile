FROM webdevops/php-nginx:8.2

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    WEB_DOCUMENT_ROOT=/var/www/html/public \
    WEB_DOCUMENT_INDEX=index.php \
    SERVICE_NGINX_CLIENT_MAX_BODY_SIZE=200M \
    PHP_UPLOAD_MAX_FILESIZE=200M \
    PHP_POST_MAX_SIZE=200M \
    PHP_MEMORY_LIMIT=512M 

# For additional supported ENV vars -> https://dockerfile.readthedocs.io/en/latest/content/DockerImages/dockerfiles/php-nginx.html

WORKDIR /var/www/html


COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY application/ /var/www/html/

RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader --no-scripts \
    && mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R application:application storage bootstrap/cache || true \
    && chmod -R ug+rwx storage bootstrap/cache || true
    

COPY entrypoint.sh /opt/docker/provision/entrypoint.d/10-laravel-init.sh
RUN chmod +x /opt/docker/provision/entrypoint.d/10-laravel-init.sh

EXPOSE 80