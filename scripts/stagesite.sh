#!/bin/bash
#
# This script deletes virtual hosts and drupal directory.
#
# Prompt user to enter Domain Name
read -p "Site domain to publish: " domain
# Prompt user to enter Git Commit Note
read -p "Please give description of planned changes: " commit
# Create variables from Domain Name
#
hosts=/etc/apache2/sites-available
www=/var/www
tld=`echo $domain  |cut -d"." -f2,3`
name=`echo $domain |cut -f1 -d"."`
shortname=`echo $name |cut -c -16`
machine=`echo $shortname |tr '-' '_'`
# Put Dev & Prod sites into Maintenance Mode
drush @$machine vset maintenance_mode 1 -y && drush @$machine cc all -y
# Git steps on Development
cd /var/www/$domain/html
git add . -A
git commit -a -m "$commit"
git push origin master
# Git steps on Production
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git pull origin master"
# Prepare site for Development
drush @$machine updb -y && drush @$machine cron -y
# Take Dev & Prod sites out of Maintenance Mode
drush @$machine vset maintenance_mode 0 -y && drush @$machine cc all -y