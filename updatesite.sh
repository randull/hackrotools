#!/bin/bash
#
# This script deletes virtual hosts and drupal directory.
#
# Prompt user to enter Domain Name
read -p "Site domain to update: " domain
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
# Git steps on Production Web Server
sudo -u deploy ssh deploy@prod "git add . -A"
sudo -u deploy ssh deploy@prod "git commit -a -m \"Preparing Git Repo for Drupal Updates on Dev Server\""
sudo -u deploy ssh deploy@prod "git push origin master"
# Git steps on Development
cd /var/www/$domain/html
git pull origin master
# Rsync steps for sites/default/files
drush -y rsync -avz @$machine.prod:%files @$machine.dev:%files
# Export DB from Prod to Dev using Drush
drush sql-sync @$machine.prod @$machine.dev -y
# Prepare site for Maintenance
drush @$machine.dev pm-disable cdn google_analytics hidden_captcha honeypot prod_check -y
drush @$machine.dev en devel_ds devel_generate devel_node_access metatag_devel devel -y
# Prepare site for Development
drush @$machine updb -y && drush @$machine cron -y
# Take Dev & Prod sites out of Maintenance Mode
drush @$machine vset maintenance_mode 0 -y && drush @$machine cc all -y