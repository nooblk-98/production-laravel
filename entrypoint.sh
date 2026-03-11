#!/bin/sh
set -eu

cd /var/www/html

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache || true
chown -R application:application storage bootstrap/cache || true
chmod -R ug+rwx storage bootstrap/cache || true


if [ -f artisan ] && [ -f vendor/autoload.php ]; then
	if ! grep -q '^APP_KEY=base64:' .env 2>/dev/null; then
		php artisan key:generate || true
	fi

	php artisan storage:link --force || true
	php artisan optimize|| true
fi