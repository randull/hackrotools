#!/bin/bash
#
# Prompt user to enter Domain Name
read -p "Domain Name: " domain
# Retrieve Variables from createsite.sh
source https://raw.github.com/randull/createsite/master/createsite.sh
echo $www
cd $www/$domain/sites/default
chmod 644 $www/$domain/sites/default/settings.php
