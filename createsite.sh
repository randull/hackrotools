#!/bin/bash
#
# Prompt user to enter Domain Name
#
read -p "Domain Name: " domain
# Create variables from Domain Name
#
www=/var/www/drupal7
name=`echo $domain |rev |cut -c 5-|rev`
echo "\$name = $name"
shortname=`echo $name |cut -c15-`
echo "\$shortname = $shortname"
tld=`echo $domain |cut -c 5-`
machine=`echo $name |tr '-' '_'`
dbpw=$(pwgen -n 16)
# Notify user of MySQL password requirement
#
echo "MySQL verification required below!"
# Create database and user
#
db="CREATE DATABASE $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u deploy -p -e "$db"
# Create directories necessary for Drupal installation
#
sudo -u deploy mkdir $www/$domain $www/$domain/sites $www/$domain/sites/default $www/$domain/sites/default/files
chmod 777 $www/$domain/sites/default/files
cd $www/$domain/sites/default/files
# Copy settings.php from github.com/drupal/*
#
cd $www/$domain/sites/default
sudo -u deploy curl -o $www/$domain/sites/default/settings.php 'https://raw.github.com/drupal/drupal/7.x/sites/default/default.settings.php'
chmod 777 $www/$domain/sites/default/settings.php 
# Populate database information in settings.php
#
perl -pi -e "s~\$databases = array\(\);~\$databases = array ( \n  'default' => \n  array ( \n    'default' => \n    array (\n      'database' => '$machine',\n      'username' => '$machine',\n      'password' => '$dbpw', \n      'host' => 'localhost', \n      'port' => '', \n      'driver' => 'mysql', \n      'prefix' => '', \n    ),\n  ),\n);~g" settings.php
# Create virtual host file, enable and restart apache
#
echo "<VirtualHost *:80>
        ServerAdmin maintenance@hackrobats.net
        DirectoryIndex index.php
        DocumentRoot $www/$domain
        ServerName www.$domain
        ServerAlias $domain *.$domain 
        ServerAlias $name.510interactive.com $name.hackrobats.net
        ServerAlias $name.5ten.co $name.cascadiacollective.net $name.cascadiaweb.net 
</VirtualHost>" > /etc/apache2/sites-available/$domain
a2ensite $domain && service apache2 reload && service apache2 restart
# Deploy site using Drush Make
#
cd $www/$domain
chmod 775 $www/$domain
sudo -u deploy drush make https://raw.github.com/randull/createsite/master/createsite.make -y
