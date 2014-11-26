#!/bin/bash
#
####    Prompt user to enter Business Name & Domain             ####
read -p "Business Name: " sitename
read -p "Domain Name: " domain
####    Prompt user to enter Password for User1(Hackrobats)     ####
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
####    Create variables from Domain Name                       ####
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
db="CREATE DATABASE IF NOT EXISTS $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw';"
db2="GRANT ALL PRIVILEGES ON $machine.* TO $machine@dev.hackrobats.net IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
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
        'password' => '$dbpw',
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
        'password' => '$dbpw',
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




####    Create site structure using Drush Make                  ####
cd /var/www/$domain/html
drush make https://raw.github.com/randull/createsite/master/createsite.make -y
####    Deploy site using Drush Site-Install                    ####
drush si createsite --db-url="mysql://$machine:$dbpw@localhost/$machine" --site-name="$sitename" --account-name="hackrobats" --account-pass="$drupalpass" --account-mail="maintenance@hackrobats.net" -y
####    Remove Drupal Install files after installation          ####
cd /var/www/$domain/html
rm CHANGELOG.txt COPYRIGHT.txt install.php INSTALL.mysql.txt INSTALL.pgsql.txt INSTALL.sqlite.txt INSTALL.txt LICENSE.txt MAINTAINERS.txt README.txt UPGRADE.txt
cd /var/www/$domain/html/sites
rm README.txt all/modules/README.txt all/themes/README.txt
sudo chown -R deploy:www-data all default
rm -R all/libraries/plupload/examples
####    Create omega 4 sub-theme and set default                ####
drush cc all
drush omega-subtheme "Hackrobats Omega Subtheme" --machine-name="omega_hackrobats"
drush omega-subtheme "$sitename" --machine-name="omega_$machine" --basetheme="omega_hackrobats" --set-default
drush omega-export "omega_$machine" --revert -y
####    Initialize Git directory                                ####
cd /var/www/$domain/html
sudo -u deploy git init
####    Set owner of entire directory to deploy:www-data        ####
cd /var/www
sudo chown -R deploy:www-data $domain
sudo chown -R deploy:www-data /home/deploy
####    Set Cron Key & Private File Path
cd /var/www/$domain/html
drush vset cron_key $machine
drush vset cron_safe_threshold 0
drush vset file_private_path /var/www/$domain/private
drush vset maintenance_mode 1
####    Clear Drupal cache, update database, run cron
drush cc all && drush updb -y && drush cron




####    Create DB & user on Production                          ####
db3="CREATE DATABASE IF NOT EXISTS $machine;GRANT ALL PRIVILEGES ON $machine.* TO $machine@localhost IDENTIFIED BY '$dbpw';"
db4="GRANT ALL PRIVILEGES ON $machine.* TO $machine@prod.hackrobats.net IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
ssh deploy@prod "mysql -u deploy -p -e '$db3'"
ssh deploy@prod "mysql -u deploy -p -e '$db4'"
####    Clone DB
drush sql-sync @$machine.dev @$machine.prod
####    Clone site directory to Production                      ####
sudo -u deploy rsync -avzh /var/www/$domain/ deploy@prod:/var/www/$domain/
####    Clone Drush aliases                                     ####
sudo -u deploy rsync -avzh /home/deploy/.drush/$machine.aliases.drushrc.php deploy@prod:/home/deploy/.drush/$machine.aliases.drushrc.php
####    Create virtual host file, enable and restart apache     ####
echo "<VirtualHost *:80>
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
        Redirect 301 / http://www.$domain
</VirtualHost>  " > deploy@prod:/etc/apache2/sites-available/$machine.conf
ssh deploy@prod "a2ensite $machine.conf && service apache2 reload"
####    Create /etc/cron.hourly entry                           ####
ssh deploy@prod "echo '#!/bin/bash
/usr/bin/wget -O - -q -t 1 http://www.$domain/sites/all/modules/elysia_cron/cron.php?cron_key=$machine' > /etc/cron.hourly/$machine"
