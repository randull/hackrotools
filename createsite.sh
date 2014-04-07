#!/bin/bash
#
# Prompt user to enter Site Name
#
read -p "Site Name: " sitename
# Prompt user to enter Domain Name
#
read -p "Domain Name: " domain
# Prompt user to enter Password for User1(Hackrobats)
#
read -p "Hackrobats Password: " drupalpass
# Create variables from Domain Name
#
www=/var/www/drupal7
tld=`echo $domain  |cut -d"." -f2,3`
name=`echo $domain |cut -f1 -d"."`
shortname=`echo $name |cut -c -15`
machine=`echo $shortname |tr '-' '_'`
dbpw=$(pwgen -n 16)
# Notify user of MySQL password requirement
#
echo "MySQL verification required."
# Create database and user
#
db="CREATE DATABASE IF NOT EXISTS $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u deploy -p -e "$db"
# Create directories necessary for Drupal installation
#
sudo -u deploy mkdir $www/$domain $www/$domain/sites $www/$domain/sites/default $www/$domain/sites/default/files
chmod 777 $www/$domain/sites/default/files
cd $www/$domain/sites/default/files
# Download favicon.ico
#
sudo -u deploy curl -o $www/$domain/favicon.ico 'http://hackrobats.net/favicon.ico'
# Create log files and folders, as well as info.php
#
sudo -u deploy mkdir $www/$domain/logs
touch $www/$domain/logs/access.log $www/$domain/logs/error.log
echo "<?php
        phpinfo();
?>" > $www/$domain/info.php
sudo chown deploy:deploy $www/$domain/info.php
# Create virtual host file, enable and restart apache
#
echo "<VirtualHost *:80>
        ServerAdmin maintenance@hackrobats.net
        ServerName www.$domain
        ServerAlias $domain *.$domain 
        ServerAlias $name.510interactive.com $name.hackrobats.net
        ServerAlias $name.5ten.co $name.cascadiacollective.net $name.cascadiaweb.net
        DocumentRoot $www/$domain
        ErrorLog $www/$domain/logs/error.log
        CustomLog $www/$domain/logs/access.log combined
        DirectoryIndex index.php
</VirtualHost>" > /etc/apache2/sites-available/$domain
a2ensite $domain && service apache2 reload && service apache2 restart
# Create site structure using Drush Make
#
cd $www/$domain
chmod 775 $www/$domain
sudo -u deploy drush make https://raw.github.com/randull/createsite/master/createsite.make -y
# Deploy site using Drush Site-Install
#
sudo -u deploy drush si createsite --db-url="mysql://$machine:$dbpw@localhost/$machine" --site-name="$sitename" --account-name="hackrobats" --account-pass="$drupalpass" --account-mail="maintenance@hackrobats.net" -y
# Remove Drupal Install files after installation
#
cd $www/$domain
rm CHANGELOG.txt COPYRIGHT.txt install.php INSTALL.mysql.txt INSTALL.pgsql.txt INSTALL.sqlite.txt INSTALL.txt LICENSE.txt MAINTAINERS.txt README.txt UPGRADE.txt
cd $www/$domain/sites
rm README.txt all/modules/README.txt all/themes/README.txt
# Create omega 4 sub-theme and set default
#
sudo drush omega-subtheme "omega_hackrobats" --enable
sudo drush omega-subtheme "$sitename" --machine-name="omega_$machine" --basetheme="omega_hackrobats" --enable
