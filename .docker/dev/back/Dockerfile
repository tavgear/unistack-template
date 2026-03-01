FROM dunglas/frankenphp:1-php8.5-trixie

ARG UID
ARG UNAME

# Install required PHP extensions
RUN install-php-extensions \
	pdo_mysql \
	intl \
	zip

# Use development PHP configuration
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

RUN \
    # Set capabilities and create development user \
    setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp && \
    getent passwd ${UID} > /dev/null 2>&1 || useradd -u ${UID} -g www-data -M ${UNAME} && \
    chown -R ${UID}:www-data /config/caddy /data/caddy

USER ${UID}