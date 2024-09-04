#!/bin/bash

# A bash script to install Apache, MySQL and Wordpress on Ubuntu

# updates the list of available packages and their versions stored in the system's package index
sudo apt update

# install apache2
sudo apt install apache2

# install mysql
sudo apt install mysql-server

# checking the current status
sudo service mysql status

# now installing dependencies for wordpress
# we already installed apache2 and mysql-server so we can skip that part

sudo apt install ghostscript \
                 libapache2-mod-php \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip

# install wordpress

echo "installing wordpress"

sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/wwwi

# Create Apache site for WordPress. Create /etc/apache2/sites-available/wordpress.conf with following lines:
echo "Creating apache site configuration file"

<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>

echo "enabling the site"
sudo a2ensite wordpress

sudo a2enmod rewrite

sudo a2dissite 000-default

echo "reloading apache server"
sudo service apache2 reload

# Creating database
echo "Creating database"

# Variables
DB_NAME="wordpress"
DB_USER="wordpress"
DB_PASS="wordpress"
ROOT_PASS="root_password"  # Replace with the MySQL root password if required

# Create database and user, and grant permissions
mysql -u root -p$ROOT_PASS <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER
    ON $DB_NAME.*
    TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "Database setup complete."

sudo service mysql start

# Configuring wordpress to connect to database

echo "Configuring wprdpress to connect to database"

echo "copying sample configuration"
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/$DB_PASS/' /srv/www/wordpress/wp-config.php





