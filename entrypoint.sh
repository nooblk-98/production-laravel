#!/bin/sh
set -eu

cd /var/www/html

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache || true
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rwx storage bootstrap/cache || true

if [ ! -f .env ] && [ -f .env.example ]; then
	cp .env.example .env
fi

if [ -f .env ]; then
	sed -i "s/^DB_HOST=.*/DB_HOST=${DB_HOST:-mariadb}/" .env || true
	sed -i "s/^DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/" .env || true
	sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-homestead}/" .env || true
	sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-homestead}/" .env || true
	sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-secret}/" .env || true
fi

if [ -f artisan ] && [ -f vendor/autoload.php ]; then
	if ! grep -q '^APP_KEY=base64:' .env 2>/dev/null; then
		php artisan key:generate || true
	fi

	php artisan optimize|| true
	php artisan storage:link || true
fi

exec "$@"