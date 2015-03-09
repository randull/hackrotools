#!/bin/bash
#
# This script Stages changes to Github, as well as Files and Database overwrite of Prod.
# Retrieve Domain Name from command line argument OR Prompt user to enter  
if [ "$1" == "" ]; 
  then
    echo "No domain provided";
    read -p "Site domain to publish: " domain;
  else
  	echo $1;
    domain=$1;
fi
# Gather commit Notes for Github repo OR prompt the user to enter  
if [ "$2" == "" ]; 
  then
    echo "No commit notes provided";
    read -p "Please give description of planned changes: " commit;
  else
  	echo $2;
    commit=$2;
fi
# Create variables from Domain Name
hosts=/etc/apache2/sites-available
www=/var/www
tld=`echo $domain  |cut -d"." -f2,3`
name=`echo $domain |cut -f1 -d"."`
shortname=`echo $name |cut -c -16`
machine=`echo $shortname |tr '-' '_'`
# Put Dev & Prod sites into Maintenance Mode
drush @$machine vset maintenance_mode 1 -y && drush @$machine cc all -y
# Fix File and Directory Permissions on Dev
cd /var/www/$domain
sudo chown -R deploy:deploy html/* logs/*
sudo chown -R www-data:www-data public/* private/* tmp/*
sudo chmod -R ug=rw,o=r,a+X logs/* private/* public/* tmp/*
sudo chmod -R u=rw,go=r,a+X html/*
# Git steps on Development
cd /var/www/$domain/html
git add . -A
git commit -a -m "$commit"
git push origin master
# Git steps on Production
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git stash"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git pull origin master"
# Rsync steps for sites/default/files
drush -y rsync -avz @$machine.dev:%files @$machine.prod:%files
# Export DB from Prod to Dev using Drush
drush sql-sync --skip-tables-list=backup_migrate_destinations @$machine.dev @$machine.prod -y
# Prepare site for Maintenance
cd /var/www/$domain/html
drush @$machine.prod en cdn googleanalytics hidden_captcha honeypot honeypot_entityform prod_check -y
drush @$machine.prod pm-disable devel_generate devel_node_access ds_devel metatag_devel devel -y
# Fix File and Directory Permissions on Prod
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chown -R deploy:deploy html/* logs/*"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chown -R www-data:www-data public/* private/* tmp/*"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chmod -R ug=rw,o=r,a+X logs/* private/* public/* tmp/*"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chmod -R u=rw,go=r,a+X html/*"
# Prepare site for Live Environment
drush @$machine cron -y && drush @$machine updb -y && drush @$machine cron -y
# Take Dev & Prod sites out of Maintenance Mode
drush @$machine vset maintenance_mode 0 -y && drush @$machine cc all -y
