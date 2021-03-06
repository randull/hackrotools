#!/bin/bash
#
# This script Creates Apache Config, DB & DB User, and empty directory within /var/www on Dev and Prod
# Also Generates Drupal site using custom Installation Profile on Dev & Clones it to Prod
#
# Retrieve Domain Name from command line argument OR Prompt user to enter
if [ "$1" == "" ]; 
  then
    echo "No domain provided";
    read -p "Site domain to generate: " domain;
  else
    echo $1;
    domain=$1;
fi
# Retrieve Business Name from command line argument OR Prompt user to enter
if [ "$2" == "" ]; 
  then
    echo "No Business Name provided";
    read -p "Please provide user friendly Business Name: " sitename;
  else
    echo $2;
    sitename=$2;
fi
# Prompt user to enter Password for User1(Hackrobats)
while true
do
    read -s -p "User1 Password: " drupalpass
    echo
    read -s -p "User1 Password (again): " drupalpass2
    echo
    [ "$drupalpass" = "$drupalpass2" ] && break
    echo "Please try again"
done
echo "Password Matches"
# Create variables from Domain Name
hosts=/etc/apache2/sites-available    # Set variable for Apache Host config
www=/var/www                          # Set variable for Drupal root directory
tld=`echo $domain  |cut -d"." -f2,3`  # Generate tld (eg .com)
name=`echo $domain |cut -f1 -d"."`    # Remove last four characters (eg .com) 
longname=`echo $name |tr '-' '_'`     # Change hyphens (-) to underscores (_)
shortname=`echo $name |cut -c -16`    # Shorten name to 16 characters for MySQL
machine=`echo $shortname |tr '-' '_'` # Replace hyphens in shortname to underscores
dbpw=$(pwgen -n 16)                   # Generate 16 character alpha-numeric password



#############################################################
#    Prepare Local Environment for Installation
#############################################################

# Clear Drush Cache
drush cc drush
# Create database and user
db1="CREATE DATABASE $machine CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw'; FLUSH PRIVILEGES;"
mysql -u deploy -e "$db1"
# Create directories necessary for Drupal installation
cd /var/www && sudo mkdir $domain && sudo chown -R deploy:www-data /var/www/$domain && sudo chmod 755 /var/www/$domain
cd /var/www/$domain && sudo mkdir html logs private public tmp && sudo chown -R deploy:www-data html logs private public tmp
cd /var/www/$domain/html && sudo mkdir -p sites/default && sudo ln -s /var/www/$domain/public sites/default/files
cd /var/www/$domain/html && sudo mkdir -p scripts/hackrobats && sudo mkdir -p profiles/hackrobats
cd /var/www/$domain && sudo touch logs/access.log logs/error.log public/readme.md tmp/readme.md
cd /var/www/$domain/private && sudo mkdir -p backup_migrate/manual backup_migrate/scheduled
cd /var/www/$domain && sudo chown -R deploy:www-data html logs private public tmp && sudo chmod 755 html logs && sudo chmod 775 private public tmp
sudo chmod -R u=rw,go=r,a+X html/*
sudo chmod -R ug=rw,o=r,a+X logs/* private/* public/* tmp/*
# Create virtual host file on Dev, enable and restart apache
echo "<VirtualHost *:80>
        ServerAdmin maintenance@hackrobats.net
        ServerName local.$domain
        ServerAlias *.$domain $name.510interactive.com $name.hackrobats.net
        ServerAlias $name.5ten.co $name.cascadiaweb.com $name.cascadiaweb.net
        DocumentRoot /var/www/$domain/html
        ErrorLog /var/www/$domain/logs/error.log
        CustomLog /var/www/$domain/logs/access.log combined
        DirectoryIndex index.php
</VirtualHost>" > /etc/apache2/sites-available/$machine.conf
sudo chown deploy:www-data /etc/apache2/sites-available/$machine.conf
sudo a2ensite $machine.conf 
sudo service apache2 reload
# Create /etc/cron.hourly entry
echo "#!/bin/bash
/usr/bin/wget -O - -q -t 1 http://local.$domain/sites/all/modules/elysia_cron/cron.php?cron_key=$machine" > /etc/cron.hourly/$machine
sudo chown deploy:www-data /etc/cron.hourly/$machine
sudo chmod 775 /etc/cron.hourly/$machine
# Create Drush Aliases
echo "<?php
\$aliases[\"local\"] = array (
  'root' => '/var/www/$domain/html',
  'uri' => 'local.$domain',
  '#name' => '$machine.local',
  '#file' => '/home/deploy/.drush/$machine.aliases.drushrc.php',
  'path-aliases' => array (
    '%drush-script' => '/usr/share/php/drush',
    '%dump-dir' => '/var/www/$domain/tmp',
    '%private' => '/var/www/$domain/private',
    '%files' => '/var/www/$domain/public',
    '%all' => 'sites/all/',
    '%site' => 'sites/default/',
  ),
  'databases' => array (
    'default' => array (
      'default' => array (
        'database' => '$machine',
        'username' => '$machine',
        'password' => '$dbpw',
        'host' => 'localhost',
        'port' => '3306',
        'driver' => 'mysql',
        'prefix' => '',
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_general_ci',
      ),
    ),
  ),
);
\$aliases[\"dev\"] = array (
  'remote-host' => 'dev.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'dev.$domain',
  '#name' => '$machine.dev',
  '#file' => '/home/deploy/.drush/$machine.aliases.drushrc.php',
  'path-aliases' => array (
    '%drush-script' => '/usr/share/php/drush',
    '%dump-dir' => '/var/www/$domain/tmp',
    '%private' => '/var/www/$domain/private',
    '%files' => '/var/www/$domain/public',
    '%all' => 'sites/all/',
    '%site' => 'sites/default/',
  ),
  'databases' => array (
    'default' => array (
      'default' => array (
        'database' => '$machine',
        'username' => '$machine',
        'password' => '$dbpw',
        'host' => 'dev.hackrobats.net',
        'port' => '3306',
        'driver' => 'mysql',
        'prefix' => '',
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_general_ci',
      ),
    ),
  ),
);
\$aliases[\"stage\"] = array (
  'remote-host' => 'stage.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'stage.$domain',
  '#name' => '$machine.stage',
  '#file' => '/home/deploy/.drush/$machine.aliases.drushrc.php',
  'path-aliases' => array (
    '%drush-script' => '/usr/share/php/drush',
    '%dump-dir' => '/var/www/$domain/tmp',
    '%private' => '/var/www/$domain/private',
    '%files' => '/var/www/$domain/public',
    '%all' => 'sites/all/',
    '%site' => 'sites/default/',
  ),
  'databases' => array (
    'default' => array (
      'default' => array (
        'database' => '$machine',
        'username' => '$machine',
        'password' => '$dbpw',
        'host' => 'stage.hackrobats.net',
        'port' => '3306',
        'driver' => 'mysql',
        'prefix' => '',
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_general_ci',
      ),
    ),
  ),
);
\$aliases[\"prod\"] = array (
  'remote-host' => 'prod.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'www.$domain',
  '#name' => '$machine.prod',
  '#file' => '/home/deploy/.drush/$machine.aliases.drushrc.php',
  'path-aliases' => array (
    '%drush-script' => '/usr/share/php/drush',
    '%dump-dir' => '/var/www/$domain/tmp',
    '%private' => '/var/www/$domain/private',
    '%files' => '/var/www/$domain/public',
    '%all' => 'sites/all/',
    '%site' => 'sites/default/',
  ),
  'databases' => array (
    'default' => array (
      'default' => array (
        'database' => '$machine',
        'username' => '$machine',
        'password' => '$dbpw',
        'host' => 'prod.hackrobats.net',
        'port' => '3306',
        'driver' => 'mysql',
        'prefix' => '',
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_general_ci',
      ),
    ),
  ),
);" > /home/deploy/.drush/$machine.aliases.drushrc.php
sudo chmod 664  /home/deploy/.drush/$machine.aliases.drushrc.php
sudo chown deploy:www-data /home/deploy/.drush/$machine.aliases.drushrc.php
# Initialize Git directory
cd /var/www/$domain/html
sudo -u deploy git init
sudo -u deploy git remote add origin git@github.com:/randull/$name.git
sudo -u deploy git branch dev
sudo -u deploy git branch stage
sudo -u deploy git pull origin master
# Create site structure using Drush Make
cd /var/www/$domain/html
drush make https://raw.github.com/randull/hackroprofile/master/hackroprofile.make --concurrency=8 --no-cache --verbose



#############################################################
#    Install Drupal on Local
#############################################################

# Deploy site using Drush Site-Install
drush site-install hackroprofile --verbose --db-url="mysql://$machine:$dbpw@localhost/$machine" --site-name="$sitename" --account-name="hackrobats" --account-pass="$drupalpass" --account-mail="maintenance@hackrobats.net"
# Remove Drupal Install files after installation
cd /var/www/$domain
sudo chown -R deploy:www-data html logs private public tmp
sudo chmod -R ug=rw,o=r,a+X public/* tmp/*
sudo chmod -R u=rw,go=r,a+X html/* logs/* private/*
cd /var/www/$domain/html
sudo mv README.txt readme.md
sudo -u deploy rm -rf modules/README.txt profiles/README.txt themes/README.txt
sudo -u deploy rm -rf CHANGELOG.txt COPYRIGHT.txt LICENSE.txt MAINTAINERS.txt README.md UPGRADE.txt
sudo -u deploy rm -rf INSTALL.mysql.txt INSTALL.pgsql.txt install.php INSTALL.sqlite.txt INSTALL.txt
sudo -u deploy rm -rf sites/README.txt sites/all/modules/README.txt sites/all/themes/README.txt
sudo -u deploy rm -rf sites/example.sites.php sites/all/libraries/plupload/examples sites/default/default.settings.php
# Prohibit Search Engines from Flagging
echo "
# Prohibit Search Engines from randomly Flagging/Unflagging content
Disallow: /flag/" >> /var/www/$domain/html/robots.txt
# Update settings.php
sudo -u deploy sed -i "259i\      'charset' => 'utf8mb4'," /var/www/$domain/html/sites/default/settings.php
sudo -u deploy sed -i "260i\      'collation' => 'utf8mb4_general_ci'," /var/www/$domain/html/sites/default/settings.php
sudo -u deploy sed -i "318i\$base_url = \'http://local.$domain\';" /var/www/$domain/html/sites/default/settings.php
sudo -u deploy sed -i "376i\$cookie_domain = \'.$domain\';" /var/www/$domain/html/sites/default/settings.php
# Set owner of entire directory to deploy:www-data
cd /var/www
sudo chown -R deploy:www-data $domain
# Set Cron Key & Private File Path
cd /var/www/$domain/html
drush vset cron_key $machine
drush vset cron_safe_threshold 0
drush vset error_level 0
drush vset file_private_path /var/www/$domain/private
drush vset file_temporary_path /var/www/$domain/tmp
drush vset jquery_update_jquery_cdn "google"
drush vset jquery_update_jquery_version "1.9"
drush vset jquery_update_jquery_admin_version "1.8"
drush vset prod_check_sitemail "maintenance@hackrobats.net"
drush vset maintenance_mode 1

drush en advanced_help

drush secrev --store

drush php-eval 'node_access_rebuild();'

# Remove Drupal Install files after installation
cd /var/www/$domain
sudo chown -R deploy:www-data html logs private public tmp
sudo chmod -R ug=rw,o=r,a+X public/* tmp/*
sudo chmod -R u=rw,go=r,a+X html/* logs/* private/*



#############################################################
#    Prepare Development and Production to Clone
#############################################################

# Set permissions
cd /var/www/$domain
sudo chown -R deploy:www-data html logs private public tmp
sudo chmod -R ug=rw,o=r,a+X public/* tmp/*
sudo chmod -R u=rw,go=r,a+X html/* logs/* private/*
# Push changes to Git directory
cd /var/www/$domain/html
sudo -u deploy git status
sudo -u deploy git add . -A
sudo -u deploy git commit -a -m "initial commit"
sudo -u deploy git push origin master
# Convert utf8 to mb4 & Create DB bash line
drush @$machine.local utf8mb4-convert-databases
db2="CREATE DATABASE IF NOT EXISTS $machine CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw'; FLUSH PRIVILEGES;"


#############################################################
#    Clone to Development
#############################################################

# Create virtual host file on Dev, enable and restart apache
sudo -u deploy ssh deploy@dev "echo '<VirtualHost *:80>
        ServerAdmin maintenance@hackrobats.net
        ServerName dev.$domain
        ServerAlias *.$domain $name.510interactive.com $name.hackrobats.net
        ServerAlias $name.5ten.co $name.cascadiaweb.com $name.cascadiaweb.net
        DocumentRoot /var/www/$domain/html
        ErrorLog /var/www/$domain/logs/error.log
        CustomLog /var/www/$domain/logs/access.log combined
        DirectoryIndex index.php
</VirtualHost>' > /etc/apache2/sites-available/$machine.conf"
# Create DB & user
sudo -u deploy ssh deploy@dev "mysql -u deploy -e \"$db2\""
# Clone site directory
sudo -u deploy rsync -avzO /var/www/$domain/ deploy@dev:/var/www/$domain/
# Change settings.php to be Dev
sudo -u deploy ssh deploy@dev "sed -i '318s/http/http/g' /var/www/$domain/html/sites/default/settings.php"
sudo -u deploy ssh deploy@dev "sed -i '318s/\$base_url/# \$base_url/g' /var/www/$domain/html/sites/default/settings.php"
sudo -u deploy ssh deploy@dev "sed -i '318s/local.$domain/dev.$domain/g' /var/www/$domain/html/sites/default/settings.php"
sudo -u deploy ssh deploy@dev "sed -i '376s/\$cookie_domain/# \$cookie_domain/g' /var/www/$domain/html/sites/default/settings.php"
# Clone Drush aliases
sudo -u deploy rsync -avzO /home/deploy/.drush/$machine.aliases.drushrc.php deploy@dev:/home/deploy/.drush/$machine.aliases.drushrc.php
# Clone Apache config & reload apache
sudo -u deploy ssh deploy@dev "sudo chown deploy:www-data /etc/apache2/sites-available/$machine.conf"
sudo -u deploy ssh deploy@dev "sudo -u deploy a2ensite $machine.conf"
sudo -u deploy ssh deploy@dev "sudo service apache2 reload"
# Clone DB
drush -v sql-sync @$machine.local @$machine.dev
# Clone cron entry
sudo -u deploy rsync -avz -e ssh /etc/cron.hourly/$machine deploy@dev:/etc/cron.hourly/$machine
sudo -u deploy ssh deploy@dev "sudo -u deploy sed -i -e 's/http/ --user=dev --password=dev --auth-no-challenge http/g' /etc/cron.hourly/$machine"
sudo -u deploy ssh deploy@dev "sudo -u deploy sed -i -e 's/local./dev./g' /etc/cron.hourly/$machine"
# Git steps
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git status"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git add . -A"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git reset --hard"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git stash"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git stash drop"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git checkout -- ."
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git pull origin master"
# Fix File and Directory Permissions
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chown -Rf deploy:www-data *"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chown -Rf deploy:www-data  html/* logs/* private/* public/* tmp/*"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod -Rf u=rw,go=r,a+X html/* logs/*"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod -Rf ug=rw,o=r,a+X private/* public/* tmp/*"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod 755 html logs"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod 775 private public tmp"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain && sudo chmod 664 html/.htaccess private/.htaccess public/.htaccess tmp/.htaccess"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf modules/README.txt profiles/README.txt themes/README.txt"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf CHANGELOG.txt COPYRIGHT.txt LICENSE.txt MAINTAINERS.txt UPGRADE.txt"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf INSTALL.mysql.txt INSTALL.pgsql.txt install.php INSTALL.sqlite.txt INSTALL.txt"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf sites/README.txt sites/all/modules/README.txt sites/all/themes/README.txt"
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && sudo rm -rf sites/example.sites.php sites/all/libraries/plupload/examples sites/default/default.settings.php"
# Rsync steps for sites/default/files on Dev
drush -v rsync -avO @$machine.local:%files @$machine.dev:%files
drush -v rsync -avO @$machine.local:%private @$machine.dev:%private


#############################################################
#    Clone to Production
#############################################################

# Create virtual host file on Prod, enable and restart apache
sudo -u deploy ssh deploy@prod "echo '<VirtualHost *:80>
        ServerAdmin maintenance@hackrobats.net
        ServerName www.$domain
        ServerAlias *.$domain $name.510interactive.com $name.hackrobats.net
        ServerAlias $name.5ten.co $name.cascadiaweb.com $name.cascadiaweb.net
        DocumentRoot /var/www/$domain/html
        ErrorLog /var/www/$domain/logs/error.log
        CustomLog /var/www/$domain/logs/access.log combined
        DirectoryIndex index.php
</VirtualHost>
<VirtualHost *:80>
        ServerName $domain
        Redirect 301 / http://www.$domain/
</VirtualHost>' > /etc/apache2/sites-available/$machine.conf"
# Create DB & user on Production
sudo -u deploy ssh deploy@prod "mysql -u deploy -e \"$db2\""
# Clone site directory to Production
sudo -u deploy rsync -avzh /var/www/$domain/ deploy@prod:/var/www/$domain/
# Change settings.php to be Dev & WWW
sudo -u deploy ssh deploy@prod "sed -i '318s/http/https/g' /var/www/$domain/html/sites/default/settings.php"
sudo -u deploy ssh deploy@prod "sed -i '318s/\$base_url/# \$base_url/g' /var/www/$domain/html/sites/default/settings.php"
sudo -u deploy ssh deploy@prod "sed -i '318s/local.$domain/www.$domain/g' /var/www/$domain/html/sites/default/settings.php"
sudo -u deploy ssh deploy@prod "sed -i '376s/\$cookie_domain/# \$cookie_domain/g' /var/www/$domain/html/sites/default/settings.php"
# Clone Drush aliases
sudo -u deploy rsync -avzO /home/deploy/.drush/$machine.aliases.drushrc.php deploy@prod:/home/deploy/.drush/$machine.aliases.drushrc.php
# Clone Apache config & reload apache
sudo -u deploy ssh deploy@prod "sudo chown deploy:www-data /etc/apache2/sites-available/$machine.conf"
sudo -u deploy ssh deploy@prod "sudo -u deploy a2ensite $machine.conf"
sudo -u deploy ssh deploy@prod "sudo service apache2 reload"
# Clone DB
drush -v sql-sync @$machine.local @$machine.prod
# Clone cron entry
sudo -u deploy rsync -avz -e ssh /etc/cron.hourly/$machine deploy@prod:/etc/cron.hourly/$machine
sudo -u deploy ssh deploy@prod "sudo -u deploy sed -i -e 's/local./www./g' /etc/cron.hourly/$machine"
# Git steps on Production
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git status"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git add . -A"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git reset --hard"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git stash"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git stash drop"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git checkout -- ."
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git pull origin master"
# Fix File and Directory Permissions on Prod
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chown -Rf deploy:www-data *"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chown -Rf deploy:www-data  html/* logs/* private/* public/* tmp/*"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chmod -Rf u=rw,go=r,a+X html/* logs/*"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chmod -Rf ug=rw,o=r,a+X private/* public/* tmp/*"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chmod 755 html logs"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chmod 775 private public tmp"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain && sudo chmod 664 html/.htaccess private/.htaccess public/.htaccess tmp/.htaccess"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && sudo rm -rf modules/README.txt profiles/README.txt themes/README.txt"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && sudo rm -rf CHANGELOG.txt COPYRIGHT.txt LICENSE.txt MAINTAINERS.txt UPGRADE.txt"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && sudo rm -rf INSTALL.mysql.txt INSTALL.pgsql.txt install.php INSTALL.sqlite.txt INSTALL.txt"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && sudo rm -rf sites/README.txt sites/all/modules/README.txt sites/all/themes/README.txt"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && sudo rm -rf sites/example.sites.php sites/all/libraries/plupload/examples sites/default/default.settings.php"
# Rsync steps for sites/default/files on Prod
drush -v rsync -avO @$machine.local:%files @$machine.prod:%files
drush -v rsync -avO @$machine.local:%private @$machine.prod:%private


#############################################################
#    Finalize Installation
#############################################################

# Take Local, Dev & Prod sites out of Maintenance Mode
drush @$machine.local vset maintenance_mode 0 && drush @$machine.local cc all
drush @$machine.dev vset maintenance_mode 0 && drush @$machine.dev cc all
drush @$machine.prod vset maintenance_mode 0 && drush @$machine.prod cc all
# Prepare site for Maintenance
drush @$machine.local dis cdn googleanalytics hidden_captcha honeypot_entityform honeypot prod_check
drush @$machine.dev dis cdn googleanalytics hidden_captcha honeypot_entityform honeypot prod_check
drush @$machine.prod dis admin_devel devel_generate devel_node_access ds_devel metatag_devel devel
# Prepare site for Live Environment
drush @$machine.local cron && drush @$machine.local updb && drush @$machine.local cron
drush @$machine.dev cron && drush @$machine.dev updb && drush @$machine.dev cron
drush @$machine.prod cron && drush @$machine.prod updb && drush @$machine.prod cron
# Take Local, Dev & Prod sites out of Maintenance Mode
drush @$machine.local vset maintenance_mode 0 && drush @$machine.local cc all
drush @$machine.dev vset maintenance_mode 0 && drush @$machine.dev cc all
drush @$machine.prod vset maintenance_mode 0 && drush @$machine.prod cc all
# Enable Xtheme and set default
cd /var/www/$domain/html/sites/all/themes/ztheme
npm install gulp --save-dev
npm install gulp-autoprefixer --save-dev
npm install gulp-sass --save-dev
npm install gulp-shell --save-dev
npm install browser-sync --save-dev
gulp sass
drush @$machine.local cron && drush @$machine.local updb && drush @$machine.local cron
drush @$machine.dev cron && drush @$machine.dev updb && drush @$machine.dev cron
drush @$machine.prod cron && drush @$machine.prod updb && drush @$machine.prod cron


# Display Docroot, URLs, Sitename, Github Repo, DB User & PW
echo ""
echo "Docroot            = /var/www/$domain/html"
echo "Domain Name        = $domain"
echo "Site Name          = $sitename"
echo "Production URL     = https://www.$domain"
echo "Staging URL        = https://stage.$domain"
echo "Development URL    = https://dev.$domain"
echo "Local URL          = http://local.$domain"
echo "Github Repository  = https://github.com/$github/$machine.git"
echo "Database Name/User = $machine"
echo "Database Password  = $dbpw"
