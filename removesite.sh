#!/bin/bash
#
# This script deletes virtual hosts and drupal directory.
#
# Disable sites-enabled symlink
www=/var/www/drupal7
hosts=/etc/apache2/sites-available
read -p "Site domain to remove: " domain
a2dissite $domain
#
# Reload Apache2
service apache2 reload
#
# Restart Apache2
service apache2 restart
#
rm $hosts/$domain
echo "$hosts/$domain disabled and removed"
#
# Delete Database & User
tld=`echo $domain |cut -c 5-`
name=`echo $domain |rev |cut -c 5-|rev`
machine=`echo $name|tr '-' '_'`
mysql -u deploy -p -e "drop database $machine;"
mysql -u deploy -p -e "drop user $machine@localhost;"
#
# Delete File Structure
cd $www
rm -R $domain
echo "$hosts/$domain directory fully removed"
