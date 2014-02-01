#!/bin/bash
#
# Prompt user to enter Domain Name
read -p "Domain Name: " domain
# Create variables from Domain Name
www=/var/www/drupal7
# Change permissions for settings.php to 644
cd $www/$domain/sites/default
chmod 644 $www/$domain/sites/default/settings.php
# Change temporary directory from /tmp to tmp
db="UPDATE files SET file_directory_temp = REPLACE(file_directory_temp,'/tmp','tmp');"
mysql -u deploy -e "$db"
