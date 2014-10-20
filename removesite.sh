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
shortname=`echo $name |cut -c -16`
machine=`echo $shortname |tr '-' '_'`
# Notify user of MySQL password requirement
#
echo "MySQL verification required."
# Delete Database & User
#
mysql -u deploy -p -e "drop database $machine;drop user $machine@localhost;"
echo "$machine database and user dropped"
# Disable sites-enabled symlink
#
a2dissite $machine.conf
# Reload Apache2
#
service apache2 reload
# Remove Virtual Host entry
#
rm $hosts/$machine.conf
if [ -d "$hosts/$machine\.conf" ]; then
  echo "$machine\.conf directory still exists in /etc/apache2/sites-available"
fi
echo "$domain Apache2 conf disabled and removed"
# Remove /etc/cron.hourly entry
#
cd /etc/cron.hourly
rm -R $machine
if [ -d "/etc/cron.hourly/$machine" ]; then
  echo "$machine entry still exists in /etc/cron.hourly"
fi
echo "$machine entry removed from /etc/cron.hourly"
# Delete File Structure
#
cd $www
rm -R $domain
if [ -d "$www/$domain" ]; then
  echo "$domain directory still exists in /var/www"
fi
echo "$domain directory removed from /var/www"
