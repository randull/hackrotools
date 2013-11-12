#!/bin/bash
#
# This script creates virtual hosts and prepares your drupal directory.
#
# Set the path to your localhost
www=/var/www/drupal
echo "Enter directory name under $www"
read -p "Site domain name: " sitedomain
mkdir $www/$sitedomain
echo "/var/www/drupal/$sitedomain created"
#
# Create a database
sitetld=`echo $sitedomain |cut -c 5-`
sitename=`echo $sitedomain |rev |cut -c 5-|rev`
machinename=`echo $sitename|tr '-' '_'`
dbuser=`echo $machinename`
dbname=`echo $machinename`
dbpw=$(pwgen -n 16)
db="create database $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -udeploy -e "$db"
#
# Check if Database Creation Failed
if [ $? != "0" ]; then
 echo "[Error]: Database creation failed"
 exit 1
else
 echo " Database has been created successfully "
 echo " DB Info: $dbname, $dbuser, $dbpw"
fi
#
# Create Settings.php /files and .htaccess
#mkdir $www/$sitedomain/sites $www/$sitedomain/sites/default $www/$sitedomain/sites/default/files
#cd $www/$sitedomain/sites/default
#curl -o $www/$sitedomain/sites/default/settings.php 'https://raw.github.com/drupal/drupal/7.x/sites/default/default.settings.php'
#chmod 777 $www/$sitedomain/sites/default/settings.php 
#chmod 775 $www/$sitedomain/sites/default/files
#
# Add Database Info to Settings.php: Replace line 213 with the following
#perl -pi -e "s~\$databases = array\(\);~\$databases = array ( \n  'default' => \n  array ( \n    'default' => \n    array (\n      'database' => '$dbname',\n      'username' => '$dbuser',\n      'password' => '$dbpw', \n      'host' => 'localhost', \n      'port' => '', \n      'driver' => 'mysql', \n      'prefix' => '', \n    ),\n  ),\n);~g" settings.php
#perl -pi -e "s~# .base_url = 'http://www.example.com';~\\\$base_url = 'http://\\$sitename\.cascadiaweb.net';~g" settings.php
#
# Create .htaccess inside of sites/default/files
#cd $www/$sitedomain/sites/default/files
#echo -n "SetHandler Drupal_Security_Do_Not_Remove_See_SA_2006_006
#Options None
#Options +FollowSymLinks" > .htaccess
#
# Create the file with VirtualHost configuration in /etc/apache2/site-available/
#echo "<VirtualHost *:80>
#        DirectoryIndex index.php
#        DocumentRoot $www/$sitedomain
#        ServerAdmin maintenance@hackrobats.net
#        ServerAlias $sitename.cascadiaweb.net $sitename.hackrobats.net
#        ServerName $sitedomain
#</VirtualHost>" > /etc/apache2/sites-available/$sitedomain
#
# Enable the site
#a2ensite $sitedomain
#
# Reload Apache2
#service apache2 reload
#
# Restart Apache2
#service apache2 restart
#
# Execute Drush Make
cd /$www/$sitedomain
chown -R deploy:deploy /$www/$sitedomain
chmod 775 /$www/$sitedomain
drush make https://raw.github.com/randull/hackrobats/master/hackrobats.make -y
