#!/bin/sh
set -eu

cd /var/www/html

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R ug+rwx storage bootstrap/cache

if [ ! -f .env ] && [ -f .env.example ]; then
	cp .env.example .env
fi

if [ -f artisan ]; then
	if ! grep -q '^APP_KEY=base64:' .env 2>/dev/null; then
		php artisan key:generate --force
	fi

	php artisan config:clear || true
	php artisan cache:clear || true
	php artisan route:clear || true
	php artisan view:clear || true

	php artisan config:cache || true
	php artisan route:cache || true
	php artisan view:cache || true

	php artisan storage:link || true
fi

exec "$@"