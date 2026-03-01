FROM dunglas/frankenphp:1-php8.5-trixie AS base

# Stage 1: Base image with PHP extensions
RUN install-php-extensions \
	pdo_mysql \
	intl \
	zip

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# Copy production configs
COPY ./.docker/prod/back/Caddyfile /etc/frankenphp/Caddyfile
COPY ./.docker/prod/back/php.ini /usr/local/etc/php/conf.d/php.ini

# Stage 2: Install PHP dependencies
FROM composer:2 AS vendor

WORKDIR /app

COPY ./back/composer.json ./back/composer.lock ./

RUN --mount=type=cache,target=/tmp/cache/composer composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Stage 3: Final production image
FROM base AS frankenphp_prod

ENV APP_ENV=prod

# Copy source code and vendors
COPY ./back /app
COPY --from=vendor /app/vendor /app/vendor

# Warm up Symfony cache
RUN php /app/bin/console cache:clear
