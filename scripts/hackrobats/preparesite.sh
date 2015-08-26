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
# Create variables from Domain Name
hosts=/etc/apache2/sites-available    # Set variable for Apache Host config
www=/var/www                          # Set variable for Drupal root directory
tld=`echo $domain  |cut -d"." -f2,3`  # Generate tld (eg .com)
name=`echo $domain |cut -f1 -d"."`    # Remove last for characters (eg .com) 
longname=`echo $name |tr '-' '_'`     # Change hyphens (-) to underscores (_)
shortname=`echo $name |cut -c -16`    # Shorten name to 16 characters for MySQL
machine=`echo $shortname |tr '-' '_'` # Replace hyphens in shortname to underscores
dbpw=$(pwgen -n 16)                   # Generate 16 character alpha-numeric password
#
#
# Create database and user on Local, Dev & Prod
db1="CREATE DATABASE IF NOT EXISTS $machine; GRANT ALL PRIVILEGES ON $machine.* TO $machine@'localhost' IDENTIFIED BY '$dbpw';"
db2="GRANT ALL PRIVILEGES ON $machine.* TO $machine@local IDENTIFIED BY '$dbpw'; GRANT ALL PRIVILEGES ON $machine.* TO $machine@local.hackrobats.net IDENTIFIED BY '$dbpw';"
db3="GRANT ALL PRIVILEGES ON $machine.* TO $machine@dev IDENTIFIED BY '$dbpw'; GRANT ALL PRIVILEGES ON $machine.* TO $machine@dev.hackrobats.net IDENTIFIED BY '$dbpw';"
db4="GRANT ALL PRIVILEGES ON $machine.* TO $machine@prod IDENTIFIED BY '$dbpw'; GRANT ALL PRIVILEGES ON $machine.* TO $machine@prod.hackrobats.net IDENTIFIED BY '$dbpw';"
mysql -u deploy -e "$db1" && sudo -u deploy ssh deploy@dev "mysql -u deploy -e \"$db1\"" && sudo -u deploy ssh deploy@prod "mysql -u deploy -e \"$db1\""
mysql -u deploy -e "$db2" && sudo -u deploy ssh deploy@dev "mysql -u deploy -e \"$db3\"" && sudo -u deploy ssh deploy@prod "mysql -u deploy -e \"$db4\""
# Create directories necessary for Drupal installation
cd /var/www && sudo mkdir $domain && sudo chown -R deploy:www-data $domain
cd /var/www/$domain && sudo mkdir html logs private public tmp && sudo chown -R deploy:www-data html logs private public tmp
cd /var/www/$domain && sudo touch logs/access.log logs/error.log public/readme.md tmp/readme.md
cd /var/www/$domain/private && sudo mkdir -p backup_migrate/manual backup_migrate/scheduled
cd /var/www/$domain && sudo chown -R deploy:www-data html logs private public tmp && sudo chmod 775 html logs private public tmp
sudo chmod -R u=rw,go=r,a+X html/*
sudo chmod -R ug=rw,o=r,a+X logs/* private/* public/* tmp/*
# Clone site directory to Development & Production
sudo -u deploy rsync -avzh /var/www/$domain/ deploy@dev:/var/www/$domain/ && sudo -u deploy rsync -avzh /var/www/$domain/ deploy@prod:/var/www/$domain/
# Create virtual host file and close to Development & Production
sudo -u deploy echo "<VirtualHost *:80>
        ServerAdmin maintenance@hackrobats.net
        ServerName local.$domain
        ServerAlias $name.510interactive.com $name.hackrobats.net
        ServerAlias $name.5ten.co $name.cascadiaweb.com $name.cascadiaweb.net
        DocumentRoot /var/www/$domain/html
        ErrorLog /var/www/$domain/logs/error.log
        CustomLog /var/www/$domain/logs/access.log combined
        DirectoryIndex index.php
</VirtualHost>" > /etc/apache2/sites-available/$machine.conf
sudo -u deploy echo "<VirtualHost *:80>
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
</VirtualHost>" > deploy@dev:/etc/apache2/sites-available/$machine.conf
sudo -u deploy rsync -avz -e ssh /etc/apache2/sites-available/$machine.conf deploy@dev:/etc/apache2/sites-available/$machine.conf
sudo -u deploy ssh deploy@dev "sudo -u deploy sed -i -e 's/local./dev./g' /etc/apache2/sites-available/$machine.conf"
sudo a2ensite $machine.conf && sudo service apache2 reload
sudo -u deploy ssh deploy@dev "sudo -u deploy a2ensite $machine.conf && sudo service apache2 reload"
sudo -u deploy ssh deploy@prod "sudo -u deploy a2ensite $machine.conf && sudo service apache2 reload"
# Create /etc/cron.hourly entry
echo "#!/bin/bash
/usr/bin/wget -O - -q -t 1 http://local.$domain/sites/all/modules/elysia_cron/cron.php?cron_key=$machine" > /etc/cron.hourly/$machine
sudo chown deploy:www-data /etc/cron.hourly/$machine
sudo chmod 775 /etc/cron.hourly/$machine
# Clone cron entry
sudo -u deploy rsync -avz -e ssh /etc/cron.hourly/$machine deploy@dev:/etc/cron.hourly/$machine
sudo -u deploy rsync -avz -e ssh /etc/cron.hourly/$machine deploy@prod:/etc/cron.hourly/$machine
sudo -u deploy ssh deploy@dev "sudo -u deploy sed -i -e 's/local./dev./g' /etc/cron.hourly/$machine"
sudo -u deploy ssh deploy@prod "sudo -u deploy sed -i -e 's/local./www./g' /etc/cron.hourly/$machine"
# Create Drush Aliases
echo "<?php
\$aliases[\"local\"] = array(
  'root' => '/var/www/$domain/html',
  'uri' => 'local.$domain',
  '#name' => '$machine.local',
  '#file' => '/home/deploy/.drush/$machine.aliases.drushrc.php',
  'path-aliases' => 
  array (
    '%drush' => '/usr/share/php/drush',
    '%dump-dir' => '/var/www/$domain/tmp',
    '%private' => '/var/www/$domain/private',
    '%files' => '/var/www/$domain/public',
    '%site' => 'sites/default/',
  ),
  'databases' =>
  array (
    'default' =>
    array (
      'default' =>
      array (
        'database' => '$machine',
        'username' => '$machine',
        'password' => '$dbpw',
        'host' => 'localhost',
        'port' => '',
        'driver' => 'mysql',
        'prefix' => '',
      ),
    ),
  ),
);
\$aliases[\"dev\"] = array(
  'remote-host' => 'dev.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'dev.$domain',
  '#name' => '$machine.dev',
  '#file' => '/home/deploy/.drush/$machine.aliases.drushrc.php',
  'path-aliases' => 
  array (
    '%drush' => '/usr/share/php/drush',
    '%dump-dir' => '/var/www/$domain/tmp',
    '%private' => '/var/www/$domain/private',
    '%files' => '/var/www/$domain/public',
    '%site' => 'sites/default/',
  ),
  'databases' =>
  array (
    'default' =>
    array (
      'default' =>
      array (
        'database' => '$machine',
        'username' => '$machine',
        'password' => '$dbpw',
        'host' => 'dev.hackrobats.net',
        'port' => '',
        'driver' => 'mysql',
        'prefix' => '',
      ),
    ),
  ),
);
\$aliases[\"prod\"] = array(
  'remote-host' => 'prod.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'www.$domain',
  '#name' => '$machine.dev',
  '#file' => '/home/deploy/.drush/$machine.aliases.drushrc.php',
  'path-aliases' => 
  array (
    '%drush' => '/usr/share/php/drush',
    '%dump-dir' => '/var/www/$domain/tmp',
    '%private' => '/var/www/$domain/private',
    '%files' => '/var/www/$domain/public',
    '%site' => 'sites/default/',
  ),
  'databases' =>
  array (
    'default' =>
    array (
      'default' =>
      array (
        'database' => '$machine',
        'username' => '$machine',
        'password' => '$dbpw',
        'host' => 'prod.hackrobats.net',
        'port' => '',
        'driver' => 'mysql',
        'prefix' => '',
      ),
    ),
  ),
);" > /home/deploy/.drush/$machine.aliases.drushrc.php
sudo chmod 664  /home/deploy/.drush/$machine.aliases.drushrc.php
sudo chown deploy:www-data /home/deploy/.drush/$machine.aliases.drushrc.php
sudo -u deploy rsync -avzh /home/deploy/.drush/$machine.aliases.drushrc.php deploy@dev:/home/deploy/.drush/$machine.aliases.drushrc.php
sudo -u deploy rsync -avzh /home/deploy/.drush/$machine.aliases.drushrc.php deploy@prod:/home/deploy/.drush/$machine.aliases.drushrc.php
# Initialize Git directory
cd /var/www/$domain/html
sudo -u deploy git init
sudo -u deploy git remote add origin git@github.com:/randull/$name.git
sudo -u deploy git pull origin master
# Push changes to Git directory
sudo -u deploy git add . -A
sudo -u deploy git commit -a -m "initial commit"
sudo -u deploy git push origin master
# Git steps on Development
sudo -u deploy rsync -avzh /var/www/$domain/.git/ deploy@dev:/var/www/$domain/.git/
sudo -u deploy rsync -avzh /var/www/$domain/.git/ deploy@prod:/var/www/$domain/.git/
sudo -u deploy ssh deploy@dev "cd /var/www/$domain/html && git stash && git pull origin master"
sudo -u deploy ssh deploy@prod "cd /var/www/$domain/html && git stash && git pull origin master"
