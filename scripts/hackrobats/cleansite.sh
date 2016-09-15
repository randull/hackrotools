#!/bin/bash
#
# This script deletes virtual hosts and drupal directory.
#
# Retrieve Domain Name from command line argument OR Prompt user to enter  
if [ "$1" == "" ]; 
  then
    echo "No arguments provided";
    read -p "Site domain to update: " domain;
  else
    echo $1;
    domain=$1;
fi
# Fix File and Directory Permissions on Local
cd /var/www/$domain/html
sudo -u deploy rm -rf modules/README.txt profiles/README.txt themes/README.txt
sudo -u deploy rm -rf CHANGELOG.txt COPYRIGHT.txt INSTALL.mysql.txt INSTALL.pgsql.txt INSTALL.sqlite.txt INSTALL.txt LICENSE.txt MAINTAINERS.txt UPGRADE.txt
sudo -u deploy rm -rf sites/README.txt sites/example.sites.php sites/all/libraries/plupload/examples sites/all/modules/README.txt sites/all/themes/README.txt sites/default/default.settings.php
echo "Unecessary files removed"
cd /var/www/$domain
sudo -u deploy chown -R deploy:www-data *
sudo -u deploy chown -R deploy:www-data html logs private public tmp
echo "File Ownership changed"
sudo -u deploy chmod -R u=rw,go=r,a+X html/* logs/*
sudo -u deploy chmod -R ug=rw,o=r,a+X private/* public/* tmp/*
sudo -u deploy chmod 775 html logs private public tmp
echo "File Permissions changed"