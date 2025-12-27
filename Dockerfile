FROM php:8.2-cli-alpine

WORKDIR /var/www/html

RUN apk add --no-cache bash git curl libzip-dev oniguruma-dev icu-dev zlib-dev jpeg-dev freetype-dev libpng-dev nodejs npm \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install pdo pdo_mysql mbstring xml bcmath gd zip

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY . /var/www/html

RUN composer install --no-dev --no-interaction --optimize-autoloader || true

RUN npm ci --no-audit --no-fund || true
RUN npm run build || true

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache || true

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "public"]
