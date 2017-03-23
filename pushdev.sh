#!/bin/bash
#
# This script deletes virtual hosts and drupal directory.
#
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
hosts=/etc/apache2/sites-available    # Set variable for Apache Host config
www=/var/www                          # Set variable for Drupal root directory
tld=`echo $domain  |cut -d"." -f2,3`  # Generate tld (eg .com)
name=`echo $domain |cut -f1 -d"."`    # Remove last for characters (eg .com) 
longname=`echo $name |tr '-' '_'`     # Change hyphens (-) to underscores (_)
shortname=`echo $name |cut -c -16`    # Shorten name to 16 characters for MySQL
machine=`echo $shortname |tr '-' '_'` # Replace hyphens in shortname to underscores
# Fix File and Directory Permissions on Local
cd /var/www/$domain/html
if [ -f "$www/$domain/html/README.md" ]; then
  sudo mv README.md readme.md
  echo "README.md has been changed to readme.md"
fi
if [ -f "$www/$domain/html/README.txt" ]; then
  sudo mv README.txt readme.md
  echo "README.txt has been changed to readme.md"
fi
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
# Git steps on Local
cd /var/www/$domain/html
git checkout .gitignore
git status
git add . -A
git commit -a -m "$commit"
git push origin master
# Git steps on Dev
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git status"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git add . -A"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git reset --hard origin/master"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git stash"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git stash drop"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git checkout -- ."
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git pull origin master"
# Rsync steps for sites/default/files
drush rsync -avO --exclude=styles/ --exclude=js/ --exclude=css/ @$machine.local:%files @$machine.dev:%files
# Flush Image Styles & Generate Styles on Local
#drush @$machine.dev image-flush --all
#drush @$machine.dev image-generate all all    //Takes 10+ minutes for Yosemite 
# Export DB from Dev to Local using Drush
drush sql-sync --skip-tables-key=common @$machine.local @$machine.dev
# Fix File and Directory Permissions on Dev
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chown -Rf deploy:www-data *"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chown -Rf deploy:www-data  html/* logs/* private/* public/* tmp/*"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod -Rf u=rw,go=r,a+X html/* logs/*"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod -Rf ug=rw,o=r,a+X private/* public/* tmp/*"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod 755 html logs"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod 775 private public tmp"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod 664 html/.htaccess private/.htaccess public/.htaccess tmp/.htaccess"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf modules/README.txt profiles/README.txt themes/README.txt"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf CHANGELOG.txt COPYRIGHT.txt LICENSE.txt MAINTAINERS.txt UPGRADE.txt"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf INSTALL.mysql.txt install.php INSTALL.pgsql.txt INSTALL.sqlite.txt INSTALL.txt"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf sites/README.txt sites/all/modules/README.txt sites/all/themes/README.txt"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf sites/example.sites.php sites/all/libraries/plupload/examples sites/default/default.settings.php"
# Prepare site for Maintenance
cd /var/www/$domain/html
drush @$machine.local dis cdn contact_google_analytics ga_tokenizer googleanalytics hidden_captcha honeypot_entityform prod_check recaptcha spambot captcha honeypot
drush @$machine.dev dis cdn contact_google_analytics ga_tokenizer googleanalytics hidden_captcha honeypot_entityform prod_check recaptcha spambot captcha honeypot
# List and Remove Missing Modules
drush @$machine.local lmm
drush @$machine.local rmm
drush @$machine.dev lmm
drush @$machine.dev rmm
# Clear Cache & Run Cron
drush @$machine.local cc all
drush @$machine.local updb
drush @$machine.dev cc all
drush @$machine.dev updb
# Prepare site for Live Environment
drush @$machine.local cron
drush @$machine.local updb
drush @$machine.dev cron
drush @$machine.dev updb