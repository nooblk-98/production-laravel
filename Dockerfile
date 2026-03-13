FROM webdevops/php-nginx:8.2

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    WEB_DOCUMENT_ROOT=/var/www/html/public \
    WEB_DOCUMENT_INDEX=index.php \
    SERVICE_NGINX_CLIENT_MAX_BODY_SIZE=200M \
    PHP_UPLOAD_MAX_FILESIZE=200M \
    PHP_POST_MAX_SIZE=200M \
    PHP_OPCACHE_MEMORY_CONSUMPTION=2048 \
    PHP_MEMORY_LIMIT=2G

# For additional supported ENV vars -> https://dockerfile.readthedocs.io/en/latest/content/DockerImages/dockerfiles/php-nginx.html

WORKDIR /var/www/html

# uncomment to enable pm2 tool inside container
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends nodejs npm \
#     && npm install -g pm2 \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*


COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY application/ /var/www/html/

RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader --no-scripts \
    && test -f vendor/autoload.php \
    && mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R application:application storage bootstrap/cache || true \
    && chmod -R ug+rwx storage bootstrap/cache || true
    

COPY entrypoint.sh /opt/docker/provision/entrypoint.d/10-laravel-init.sh
RUN chmod +x /opt/docker/provision/entrypoint.d/10-laravel-init.sh

EXPOSE 80
