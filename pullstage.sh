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
# Create variables from Domain Name
hosts=/etc/apache2/sites-available    # Set variable for Apache Host config
www=/var/www                          # Set variable for Drupal root directory
tld=`echo $domain  |cut -d"." -f2,3`  # Generate tld (eg .com)
name=`echo $domain |cut -f1 -d"."`    # Remove last for characters (eg .com) 
longname=`echo $name |tr '-' '_'`     # Change hyphens (-) to underscores (_)
shortname=`echo $name |cut -c -16`    # Shorten name to 16 characters for MySQL
machine=`echo $shortname |tr '-' '_'` # Replace hyphens in shortname to underscores
# Fix File and Directory Permissions on Staging
sudo -u deploy ssh deploy@stage "cd /var/www/$domain && sudo chown -Rf deploy:www-data *"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain && sudo chown -Rf deploy:www-data  html/* logs/* private/* public/* tmp/*"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain && sudo chmod -Rf u=rw,go=r,a+X html/* logs/*"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain && sudo chmod -Rf ug=rw,o=r,a+X private/* public/* tmp/*"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain && sudo chmod 755 html logs"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain && sudo chmod 775 private public tmp"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain && sudo chmod 664 html/.htaccess private/.htaccess public/.htaccess tmp/.htaccess"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain/html && sudo rm -rf modules/README.txt profiles/README.txt themes/README.txt"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain/html && sudo rm -rf CHANGELOG.txt COPYRIGHT.txt LICENSE.txt MAINTAINERS.txt UPGRADE.txt"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain/html && sudo rm -rf INSTALL.mysql.txt INSTALL.pgsql.txt install.php INSTALL.sqlite.txt INSTALL.txt"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain/html && sudo rm -rf sites/README.txt sites/all/modules/README.txt sites/all/themes/README.txt"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain/html && sudo rm -rf sites/example.sites.php sites/all/libraries/plupload/examples sites/default/default.settings.php"
# Fix file ownership
cd /var/www/$domain
sudo chown -Rf deploy:www-data *
sudo chown -Rf deploy:www-data html/* logs/* private/* public/* tmp/*
echo "File Ownership fixed"
# Fix file permissions
sudo chmod -Rf u=rw,go=r,a+X html/* logs/*
sudo chmod -Rf ug=rw,o=r,a+X private/* public/* tmp/*
sudo chmod 755 html logs
sudo chmod 775 private public tmp
sudo chmod 644 html/.htaccess private/.htaccess public/.htaccess tmp/.htaccess
echo "File Permissions fixed"
# Remove unecessary files
cd /var/www/$domain/html
sudo rm -rf modules/README.txt profiles/README.txt themes/README.txt
sudo rm -rf CHANGELOG.txt COPYRIGHT.txt LICENSE.txt MAINTAINERS.txt UPGRADE.txt
sudo rm -rf INSTALL.mysql.txt INSTALL.pgsql.txt install.php INSTALL.sqlite.txt INSTALL.txt
sudo rm -rf sites/README.txt sites/all/modules/README.txt sites/all/themes/README.txt
sudo rm -rf sites/example.sites.php sites/all/libraries/plupload/examples sites/default/default.settings.php
echo "Unecessary files removed"
# Checkout all changes on Local Environment
cd /var/www/$domain/html
git status
git add . -A
git reset --hard origin/master
git stash
git stash drop
git checkout -- .
git status
# Git steps on Staging Web Server
sudo -u deploy ssh deploy@stage "cd /var/www/$domain/html && git status"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain/html && git add . -A"
sudo -u deploy ssh deploy@stage "cd /var/www/$domain/html && git commit -a -m \"Preparing Git Repo for Drupal Updates on Local Server\""
sudo -u deploy ssh deploy@stage "cd /var/www/$domain/html && git push origin master"
# Git steps on Staging
git status
git diff
git pull origin master
# Rsync steps for sites/default/files
drush -v rsync -avO --exclude=styles/ --exclude=js/ --exclude=css/ @$machine.stage:%files @$machine.local:%files
# Export DB from Staging to Local using Drush
drush -v sql-sync --skip-tables-key=common @$machine.stage @$machine.local
# Flush Image Styles & Generate Styles on Local
#drush @$machine.local image-flush --all
#drush @$machine.local image-generate all all
# Clear Cache & Run Cron
drush @$machine.local cc all
drush @$machine.local updb
drush @$machine.stage cc all
drush @$machine.stage updb
# Prepare site for Maintenance
cd /var/www/$domain/html
drush @$machine.local dis advagg_bundler advagg_css_compress advagg_validator advagg_ext_compress advagg_mod advagg_relocate advagg_sri advagg
drush @$machine.local dis cdn contact_google_analytics ga_tokenizer googleanalytics hidden_captcha honeypot_entityform prod_check recaptcha spambot captcha honeypot
#drush @$machine.local en devel admin_devel browsersync devel_generate devel_node_access ds_devel metatag_devel reroute_email
# List and Remove Missing Modules
drush @$machine.local lmm
drush @$machine.local rmm
drush @$machine.stage lmm
drush @$machine.stage rmm
# Prepare site for Staging
drush @$machine.local cron
drush @$machine.local updb
drush @$machine.local cc all
drush @$machine.stage cron
drush @$machine.stage updb
drush @$machine.stage cc all
