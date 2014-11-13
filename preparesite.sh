#!/bin/bash
#
####    Prompt user to enter Site Name                          ####
read -p "Site Name: " sitename
####    Prompt user to enter Domain Name                        ####
read -p "Domain Name: " domain
####    Prompt user to enter Password for User1(Hackrobats)     ####
#while true
#do
#    read -s -p "User1 Password: " drupalpass
#    echo
#    read -s -p "User1 Password (again): " drupalpass2
#    echo
#    [ "$drupalpass" = "$drupalpass2" ] && break
#    echo "Please try again"
#done
#echo "Password Matches"
####    Create variables from Domain Name                       ####
www=/var/www
tld=`echo $domain  |cut -d"." -f2,3`
name=`echo $domain |cut -f1 -d"."`
shortname=`echo $name |cut -c -16`
machine=`echo $shortname |tr '-' '_'`
dbpw=$(pwgen -n 16)
####    Print DB Password for reference                         ####
echo "$dbpw"
####    Notify user of MySQL password requirement               ####
echo "MySQL verification required."
####    Create database and user                                ####
db="CREATE DATABASE IF NOT EXISTS $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u deploy -p -e "$db"
####    Create directories necessary for Drupal installation    ####
sudo -u deploy mkdir $www/$domain $www/$domain/html $www/$domain/html/sites $www/$domain/html/sites/default $www/$domain/html/sites/default/files
chmod a+w $www/$domain/html/sites/default/files
chgrp -R www-data $www/$domain
cd $www/$domain/html/sites/default/files
####    Create Private directory and setup Backup directories   ####
sudo -u deploy mkdir -p $www/$domain/private/backup_migrate/scheduled $www/$domain/private/backup_migrate/manual
chmod 6774 -R $www/$domain/private
chown -R deploy:www-data $www/$domain/private
####    Download favicon.ico                                    ####
sudo -u deploy curl -o $www/$domain/html/sites/default/files/favicon.ico 'http://hackrobats.net/sites/default/files/favicon.ico'
####    Create Public & Temp files directory                           ####
mkdir $www/$domain/public $www/$domain/tmp
chmod 6775 -R $www/$domain/public $www/$domain/tmp
chown -R deploy:www-data $www/$domain/public $www/$domain/tmp
####    Create log files and folders, as well as info.php       ####
sudo -u deploy mkdir $www/$domain/logs
touch $www/$domain/logs/access.log $www/$domain/logs/error.log
echo "<?php
        phpinfo();
?>" > $www/$domain/html/info.php
sudo chown deploy:www-data $www/$domain/html/info.php
####    Create virtual host file, enable and restart apache     ####
echo "<VirtualHost *:80>
        ServerAdmin maintenance@hackrobats.net
        ServerName www.$domain
        ServerAlias *.$domain $name.510interactive.com $name.hackrobats.net
        ServerAlias $name.5ten.co $name.cascadiaweb.net
        DocumentRoot $www/$domain/html
        ErrorLog $www/$domain/logs/error.log
        CustomLog $www/$domain/logs/access.log combined
        DirectoryIndex index.php
</VirtualHost>
<VirtualHost *:80>
        ServerName $domain
        Redirect 301 / http://www.$domain
</VirtualHost>  " > /etc/apache2/sites-available/$machine.conf
a2ensite $machine.conf && service apache2 reload
####    Create /etc/cron.hourly entry                           ####
echo "#!/bin/bash
/usr/bin/wget -O - -q -t 1 http://$domain/sites/all/modules/elysia_cron/cron.php?cron_key=$machine" > /etc/cron.hourly/$machine
####    Create Drush Aliases                                    ####
echo "<?php
\$aliases[\"dev\"] = array(
  'remote-host' => 'dev.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'dev.$domain',
);
\$aliases[\"prod\"] = array(
  'remote-host' => 'prod.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'www.$domain',
);\$aliases[\"olddev\"] = array(
  'remote-host' => 'olddev.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'dev.$domain',
);
\$aliases[\"oldprod\"] = array(
  'remote-host' => 'oldprod.hackrobats.net',
  'remote-user' => 'deploy',
  'root' => '/var/www/$domain/html',
  'uri' => 'www.$domain',
);" > /home/deploy/.drush/$machine.aliases.drushrc.php
sudo chmod 664  /home/deploy/.drush/$machine.aliases.drushrc.php
sudo chown deploy:www-data /home/deploy/.drush/$machine.aliases.drushrc.php
