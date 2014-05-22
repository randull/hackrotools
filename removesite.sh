#!/bin/bash
#
# This script deletes virtual hosts and drupal directory.
#
# Prompt user to enter Domain Name
#
read -p "Site domain to remove: " domain
# Create variables from Domain Name
#
hosts=/etc/apache2/sites-available
www=/var/www/drupal7
tld=`echo $domain  |cut -d"." -f2,3`
name=`echo $domain |cut -f1 -d"."`
shortname=`echo $name |cut -c -15`
machine=`echo $shortname |tr '-' '_'`
# Disable sites-enabled symlink
#
a2dissite $domain
# Reload Apache2
#
service apache2 reload
# Remove Virtual Host entry
#
rm $hosts/$domain
echo "$hosts/$domain Virtualhost disabled and removed"
# Notify user of MySQL password requirement
#
echo "MySQL verification required."
# Delete Database & User
#
mysql -u deploy -p -e "drop database $machine;drop user $machine@localhost;"
echo "$machine database and user dropped"
# Delete File Structure
#
cd $www
rm -R $domain
echo "$hosts/$domain directory fully removed"
