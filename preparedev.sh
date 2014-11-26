#!/bin/bash
#
####    Prompt user to enter Site Name                          ####
#read -p "Site Name: " sitename
####    Prompt user to enter Domain Name                        ####
read -p "Domain Name: " domain
####    Create variables from Domain Name                       ####
tld=`echo $domain  |cut -d"." -f2,3`
name=`echo $domain |cut -f1 -d"."`
shortname=`echo $name |cut -c -16`
machine=`echo $shortname |tr '-' '_'`
dbpwdev=$(pwgen -n 16)
dbpwtest=$(pwgen -n 16)
dbpwprod=$(pwgen -n 16)
####    Print DB Password for reference                         ####
echo "$dbpwdev"
echo "$dbpwtest"
echo "$dbpwprod"
####    Notify user of MySQL password requirement               ####
echo "MySQL verification required."
####    Create database and user                                ####
db="CREATE DATABASE IF NOT EXISTS $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpwdev';"
db="GRANT ALL PRIVILEGES ON $machine.* TO $machine@dev.hackrobats.net IDENTIFIED BY '$dbpwdev';FLUSH PRIVILEGES;"
mysql -u deploy -p -e "$db"
mysql -u deploy -p -e "$db2"
####    Create directories necessary for Drupal installation    ####
cd /var/www && sudo -u deploy mkdir $domain
cd /var/www/$domain && sudo -u deploy mkdir html logs private public tmp
cd /var/www/$domain/html && sudo -u deploy mkdir -p sites/default && sudo -u deploy ln -s /var/www/$domain/public sites/default/files
cd /var/www/$domain/logs && touch access.log error.log
cd /var/www/$domain/private && sudo -u deploy mkdir -p backup_migrate/manual backup_migrate/scheduled
cd /var/www/$domain && sudo chmod 6775 html logs public private tmp
####    Create virtual host file, enable and restart apache     ####
echo "<VirtualHost *:80>
        ServerAdmin maintenance@hackrobats.net
        ServerName dev.$domain
        ServerAlias *.$domain $name.510interactive.com $name.hackrobats.net
        ServerAlias $name.5ten.co $name.cascadiaweb.com $name.cascadiaweb.net
        DocumentRoot /var/www/$domain/html
        ErrorLog /var/www/$domain/logs/error.log
        CustomLog /var/www/$domain/logs/access.log combined
        DirectoryIndex index.php
</VirtualHost>
<VirtualHost *:80>
        ServerName $domain
        Redirect 301 / http://dev.$domain
</VirtualHost>  " > /etc/apache2/sites-available/$machine.conf
a2ensite $machine.conf && service apache2 reload
####    Create /etc/cron.hourly entry                           ####
echo "#!/bin/bash
/usr/bin/wget -O - -q -t 1 http://dev.$domain/sites/all/modules/elysia_cron/cron.php?cron_key=$machine" > /etc/cron.hourly/$machine
####    Create Drush Aliases                                    ####
echo "<?php
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
        'password' => '$dbpwdev',
        'host' => 'dev.hackrobats.net',
        'port' => '',
        'driver' => 'mysql',
        'prefix' => '',
      ),
    ),
  ),
);
\$aliases[\"test\"] = array(
  'remote-host' => 'test.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'test.$domain',
  '#name' => '$machine.test',
  '#file' => '/home/deploy/.drush/$machine.aliases.drushrc.php',
  'path-aliases' => 
  array (
    '%drush' => '/usr/share/php/drush',
    '%dump-dir' => '/var/www/$domain/tmp',
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
        'password' => '$dbpwtest',
        'host' => 'test.hackrobats.net',
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
        'password' => '$dbpwprod',
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
####    Pass Variables to Createsite.sh                         ####
export domain
sudo bash -c "$(curl -fsSL https://raw.github.com/randull/createsite/master/createsite.sh)" -y
