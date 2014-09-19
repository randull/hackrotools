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
www=/var/www
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
echo "$domain Apache2 conf disabled and removed"
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
if [ -d "$domain" ]; then
  echo "$domain directory still exists in /var/www"
fi
echo "$domain directory removed from /var/www"
