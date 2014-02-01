#!/bin/bash
#
# Prompt user to enter Domain Name
read -p "Domain Name: " domain
# Create variables from Domain Name
www=/var/www/drupal7
# Change permissions for settings.php to 644
cd $www/$domain/sites/default
chmod 644 $www/$domain/sites/default/settings.php
