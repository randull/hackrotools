#!/bin/bash
#!/usr/bin/php
#
# Prompt user to enter Domain Name
#
read -p "Domain Name: " domain
# Create variables from Domain Name
#
www=/var/www/drupal7
name=`echo $domain |rev |cut -c 5-|rev`
machine=`echo $name |tr '-' '_'`
# Remove Drupal Install files
#
cd $www/$domain
rm CHANGELOG.txt COPYRIGHT.txt install.php INSTALL.mysql.txt INSTALL.pgsql.txt INSTALL.sqlite.txt INSTALL.txt LICENSE.txt MAINTAINERS.txt UPGRADE.txt
# Change permissions for settings.php to 644
#
cd $www/$domain/sites/default
chmod 644 $www/$domain/sites/default/settings.php
# Create omega 4 sub-theme and set default
#
drush omega-subtheme $machine
drush vset theme_default $machine
