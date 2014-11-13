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
#dbpw=$(pwgen -n 16)
####    Print DB Password for reference                         ####
#echo "$dbpw"
####    Notify user of MySQL password requirement               ####
#echo "MySQL verification required."
####    Create database and user                                ####
#db="CREATE DATABASE IF NOT EXISTS $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
#mysql -u deploy -p -e "$db"
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
        ServerName www.$domain
        ServerAlias *.$domain $name.510interactive.com $name.hackrobats.net
        ServerAlias $name.5ten.co $name.cascadiaweb.net
        DocumentRoot /var/www/$domain/html
        ErrorLog /var/www/$domain/logs/error.log
        CustomLog /var/www/$domain/logs/access.log combined
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
####    Pass Variables to Createsite.sh                         ####
export domain
sudo bash -c "$(curl -fsSL https://raw.github.com/randull/createsite/master/createsite.sh)" -y
