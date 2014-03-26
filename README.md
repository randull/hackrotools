CONTENTS OF THIS FILE
---------------------

 * About Drupal
 * Configuration and features
 * Installation profiles
 * Appearance
 * Developing for Drupal

PREREQUISITS
--------------------------
 * LAMP stack
 * cURL
 * Git
 * Drush
 * Pwgen

INSTALLATION PROFILE
---------------------

Modules Included:
 * admin_menu
 * breakpoints
 * ckeditor
 * ctools
 * devel
 * flexslider
 * libraries
 * module_filter
 * picture
 * prod_check
 * security_review
 * views


APPEARANCE
----------

Default Theme: Omega 4
Admin Theme: Shiny

INSTALLATION INSTRUCTIONS
---------------------

1.) Execute the following line in your terminal:

sudo bash -c "$(curl -fsSL https://raw.github.com/randull/createsite/master/createsite.sh)" -y

2.) Enter Domain Name

3.) Navigate your browser to http://SITENAME.cascadiaweb.net/install.php?profile=createsite&locale=en

4.) Execute the following line in your terminal:

  sudo bash -c "$(curl -fsSL https://raw.github.com/randull/createsite/master/postinstall.sh)" -y
