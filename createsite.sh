#!/bin/bash
#
# This script creates virtual hosts and prepares your drupal directory and database.
read -p "Domain Name: " domain

www=/var/www/drupal7
name=`echo $domain |rev |cut -c 5-|rev`
tld=`echo $domain |cut -c 5-`
machine=`echo $name |tr '-' '_'`
dbpw=$(pwgen -n 16)
echo "Site name: $name 
Created at: $www/$domain 
Machine name: $machine 
Password: $dbpw"

db="create database $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -udeploy -e "$db"

mkdir $www/$domain $www/$domain/sites $www/$domain/sites/default $www/$domain/sites/default/files
echo "Created: $domain/sites 
$domain/sites/default 
$domain/sites/default/files"

cd $www/$domain/sites/default
curl -o $www/$domain/sites/default/settings.php 'https://raw.github.com/drupal/drupal/7.x/sites/default/default.settings.php'
chmod 775 $www/$domain/sites/default/files
chmod 777 $www/$domain/sites/default/settings.php 
echo "Copied: default.settings.php
From: github.com/drupal
To: $domain/sites/default/settings.php"

#perl -pi -e "s~\$databases = array\(\);~\$databases = array ( \n  'default' => \n  array ( \n    'default' => \n    array (\n      'database' => '$dbname',\n      'username' => '$dbuser',\n      'password' => '$dbpw', \n      'host' => 'localhost', \n      'port' => '', \n      'driver' => 'mysql', \n      'prefix' => '', \n    ),\n  ),\n);~g" settings.php
#perl -pi -e "s~# .base_url = 'http://www.example.com';~\\\$base_url = 'http://\\$sitename\.cascadiaweb.net';~g" settings.php

#cd $www/$sitedomain/sites/default/files
#echo -n "SetHandler Drupal_Security_Do_Not_Remove_See_SA_2006_006
#Options None
#Options +FollowSymLinks" > .htaccess

echo "<VirtualHost *:80>
        DirectoryIndex index.php
        DocumentRoot $www/$domain
        ServerAdmin maintenance@hackrobats.net
        ServerAlias $name.cascadiaweb.net $name.hackrobats.net
        ServerName $domain
</VirtualHost>" > /etc/apache2/sites-available/$domain

#a2ensite $domain
#service apache2 reload
#service apache2 restart

cd $www/$domain
chown -R deploy:deploy $www/$domain
chmod 775 $www/$domain
drush make https://raw.github.com/randull/createsite/master/createsite.make -y
