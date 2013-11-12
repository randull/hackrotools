#!/bin/bash
#
# This script deletes virtual hosts and drupal directory.
#
# Disable sites-enabled symlink
www=/var/www/drupal
hosts=/etc/apache2/sites-available
read -p "Site domain to remove: " sitedomain
a2dissite $sitedomain
#
# Reload Apache2
service apache2 reload
#
# Restart Apache2
service apache2 restart
#
rm $hosts/$sitedomain
echo "$hosts/$sitedomain disabled and removed"
#
# Delete Database & User
sitetld=`echo $sitedomain |cut -c 5-`
sitename=`echo $sitedomain |rev |cut -c 5-|rev`
machinename=`echo $sitename|tr '-' '_'`
dbuser=`echo $machinename`
dbname=`echo $machinename`
mysql -u deploy -e "drop database $dbname;"
mysql -u deploy -e "drop user $dbuser@localhost;"
#
# Delete File Structure
cd $www
rm -R $sitedomain
echo "$hosts/$sitedomain directory fully removed"
