core = 7.x
api = 2

; Drupal Core
projects[drupal][type] = core
projects[drupal][version] = 7.23
projects[drupal][download][type] = get
projects[drupal][download][url] = http://ftp.drupal.org/files/projects/drupal-7.23.tar.gz

; Modules
projects[] = admin_menu
projects[] = breakpoints
projects[] = ckeditor
projects[] = ctools
projects[] = flexslider
projects[] = libraries
projects[] = module_filter
projects[] = picture
projects[] = prod_check
projects[] = security_review
projects[] = views

; Custom Install Profile
projects[createsite][type] = "profile"
projects[createsite][download][type] = "git"
projects[createsite][download][url] = "git://github.com/randull/createsite.git"
