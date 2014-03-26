#!/bin/bash
#!/usr/bin/php
#
# Prompt user to enter Domain Name
#
read -p "Domain Name: " domain
# Create variables from Domain Name
#
www=/var/www/drupal7
tld=`echo $domain  |cut -d"." -f2,3`
name=`echo $domain |cut -f1 -d"."`
shortname=`echo $name |cut -c -15`
machine=`echo $shortname |tr '-' '_'`
# Remove Drupal Install files
#
cd $www/$domain
rm CHANGELOG.txt COPYRIGHT.txt install.php INSTALL.mysql.txt INSTALL.pgsql.txt INSTALL.sqlite.txt INSTALL.txt LICENSE.txt MAINTAINERS.txt README.txt UPGRADE.txt
cd $www/$domain/sites
rm README.txt all/modules/README.txt all/themes/README.txt
# Change permissions for settings.php to 644
#
cd $www/$domain/sites/default
chmod 644 $www/$domain/sites/default/settings.php
# Create omega 4 sub-theme and set default
#
drush omega-subtheme $machine
drush vset theme_default $machine
