# Usa una imagen de PHP con Apache
FROM php:8.2-apache

# Habilita mod_dir para asegurar que index.php e index.html funcionen
RUN a2enmod dir

# Configura el DirectoryIndex manualmente en Apache
RUN echo "<IfModule mod_dir.c>\n    DirectoryIndex index.php index.html\n</IfModule>" \
    > /etc/apache2/mods-enabled/dir.conf

    
# Ajusta permisos de la carpeta pública
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Reinicia Apache para aplicar cambios
RUN service apache2 restart

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y libpq-dev libpng-dev zip unzip curl \
    && docker-php-ext-install pdo pdo_mysql

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia los archivos del proyecto
COPY . /var/www/html

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Instala dependencias de Laravel
RUN composer install --no-dev --optimize-autoloader

# Exponer el puerto 80
EXPOSE 80

# Ejecutar Apache en segundo plano
CMD ["apache2-foreground"]
