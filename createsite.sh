#!/bin/bash
#
# Prompt user to enter Domain Name
read -p "Domain Name: " domain
# Create variables from Domain Name
www=/var/www/drupal7
name=`echo $domain |rev |cut -c 5-|rev`
tld=`echo $domain |cut -c 5-`
machine=`echo $name |tr '-' '_'`
dbpw=$(pwgen -n 16)
# Create database and user
db="create database $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u root -e "$db"
# Create directories necessary for Drupal installation
sudo -u deploy mkdir $www/$domain $www/$domain/sites $www/$domain/sites/default $www/$domain/sites/default/files
chmod 775 $www/$domain/sites/default/files
cd $www/$domain/sites/default/files
# Copy settings.php from github.com/drupal/*
cd $www/$domain/sites/default
sudo -u deploy curl -o $www/$domain/sites/default/settings.php 'https://raw.github.com/drupal/drupal/7.x/sites/default/default.settings.php'
chmod 777 $www/$domain/sites/default/settings.php 
# Populate database information in settings.php
perl -pi -e "s~\$databases = array\(\);~\$databases = array ( \n  'default' => \n  array ( \n    'default' => \n    array (\n      'database' => '$machine',\n      'username' => '$machine',\n      'password' => '$dbpw', \n      'host' => 'localhost', \n      'port' => '', \n      'driver' => 'mysql', \n      'prefix' => '', \n    ),\n  ),\n);~g" settings.php
# Create virtual host file, enable and restart apache
echo "<VirtualHost *:80>
        DirectoryIndex index.php
        DocumentRoot $www/$domain
        ServerAdmin maintenance@hackrobats.net
        ServerAlias $name.cascadiaweb.net $name.hackrobats.net
        ServerName $domain
</VirtualHost>" > /etc/apache2/sites-available/$domain
a2ensite $domain && service apache2 reload && service apache2 restart
# Deploy site using Drush Make
cd $www/$domain
chown -R deploy:deploy $www/$domain
chmod 775 $www/$domain
sudo -u deploy drush make https://raw.github.com/randull/createsite/master/createsite.make -y
