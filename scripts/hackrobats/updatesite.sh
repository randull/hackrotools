#!/bin/bash
#
# This script deletes virtual hosts and drupal directory.
#
# Prompt user to enter Domain Name
read -p "Site domain to update: " domain
# Prompt user to enter Git Commit Note
#read -p "Please give description of planned changes: " commit
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
# Fix File and Directory Permissions on Prod
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chown -R deploy:deploy html/*"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chown -R www-data:www-data logs/* private/* public/* tmp/*"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chmod -R ug=rw,o=r,a+X logs/* private/* public/* tmp/*"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chmod -R u=rw,go=r,a+X html/*"
# Fix File and Directory Permissions on Dev
cd /var/www/$domain
sudo chown -R deploy:deploy html/*
sudo chown -R www-data:www-data logs/* private/* public/* tmp/*
sudo chmod -R ug=rw,o=r,a+X logs/* private/* public/* tmp/*
sudo chmod -R u=rw,go=r,a+X html/*
# Checkout all changes on Development Web Server
cd /var/www/$domain/html
git reset
git checkout .
git checkout -- .
# Git steps on Production Web Server
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git status"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git add . -A"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git commit -a -m \"Preparing Git Repo for Drupal Updates on Dev Server\""
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git push origin master"
# Git steps on Development
git status
git pull origin master
# Rsync steps for sites/default/files
drush -y rsync -avz @$machine.prod:%files @$machine.dev:%files
# Export DB from Prod to Dev using Drush
drush sql-sync --skip-tables-list=backup_migrate_destinations @$machine.prod @$machine.dev -y
# Prepare site for Maintenance
cd /var/www/$domain/html
drush @$machine.dev pm-disable cdn googleanalytics google_analytics hidden_captcha honeypot prod_check -y
drush @$machine.dev en devel_generate devel_node_access ds_devel metatag_devel devel -y
# Prepare site for Development
drush @$machine updb -y && drush @$machine cron -y
# Take Dev & Prod sites out of Maintenance Mode
drush @$machine vset maintenance_mode 0 -y && drush @$machine cc all -y
