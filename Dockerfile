# ---------------------------------------------
# Étape 1 : installation des dépendances PHP (composer)
# ---------------------------------------------
FROM composer:2 AS vendor

RUN echo 'Acquire::AllowInsecureRepositories "true";' > /etc/apt/apt.conf.d/99insecure && \
    echo 'Acquire::AllowUnsignedRepositories "true";' >> /etc/apt/apt.conf.d/99insecure && \
    apt-get update && \
    apt-get install -y unzip curl && \
    docker-php-ext-install bcmath pdo pdo_mysql && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app

# Copie les fichiers nécessaires pour installer les dépendances PHP
COPY composer.json composer.lock ./

# Installation des dépendances PHP (y compris celles de développement)
RUN composer install --no-interaction --prefer-dist --no-scripts

# ---------------------------------------------
# Étape 2 : compilation du front avec Vite
# ---------------------------------------------
FROM node:20 AS build_front

WORKDIR /app

# Installation des dépendances npm
COPY package*.json ./
RUN npm install

# Copie des fichiers nécessaires à la compilation front
COPY resources/ resources/
COPY vite.config.js tailwind.config.js postcss.config.js ./

# Compilation du front pour la production
RUN npm run build

# ---------------------------------------------
# Étape 3a : environnement de développement
# ---------------------------------------------
FROM php:8.2-apache AS dev

WORKDIR /var/www/html

# Installation des dépendances système et extensions PHP nécessaires
RUN apt-get update && apt-get install -y unzip curl libzip-dev && \
    docker-php-ext-install pdo pdo_mysql bcmath && \
    a2enmod rewrite

# Installer Composer dans le conteneur dev
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copie l'intégralité du projet dans le conteneur
COPY . .

# Configuration du DocumentRoot pour pointer vers le dossier public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf
RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Création des dossiers nécessaires et application des bonnes permissions
RUN mkdir -p \
    storage/framework/views \
    storage/framework/cache/data \
    bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap && \
    chmod -R 755 storage bootstrap

# Copie du script d’entrée
COPY docker/entrypoint.sh /entrypoint.sh

# Rend le script exécutable
RUN chmod +x /entrypoint.sh

# Définit le point d’entrée du conteneur
ENTRYPOINT ["/entrypoint.sh"]

# ---------------------------------------------
# Étape 3b : environnement de production
# ---------------------------------------------
FROM php:8.2-apache AS prod

WORKDIR /var/www/html

# Installation des extensions PHP requises
RUN docker-php-ext-install pdo pdo_mysql
RUN a2enmod rewrite

# Copie du code source
COPY . .

# Ajout des dépendances PHP et des fichiers compilés du front
COPY --from=vendor /app/vendor ./vendor
COPY --from=build_front /app/public/build ./public/build

# Configuration du DocumentRoot
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf
RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Création des dossiers nécessaires et application des bonnes permissions
RUN mkdir -p \
    storage/framework/views \
    storage/framework/cache/data \
    bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap && \
    chmod -R 755 storage bootstrap

# Copie du script d’entrée
COPY docker/entrypoint.sh /entrypoint.sh

# Rend le script exécutable
RUN chmod +x /entrypoint.sh

# Définit le point d’entrée du conteneur
ENTRYPOINT ["/entrypoint.sh"]
