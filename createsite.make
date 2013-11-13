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

; Themes
projects[omega][type] = theme
projects[omega][version] = 4
projects[omega][download][type] = git
projects[omega][download][url] = http://git.drupal.org/project/omega.git
projects[omega][download][branch] = 7.x-4.x
projects[shiny][type] = theme
projects[shiny][version = 1.3
projects[shiny][download][type] = git
projects[shiny][download][url] = http://git.drupal.org/project/shiny.git
projects[shiny][download][branch] = 7.x-1.x

; Libraries
libraries[ckeditor][directory_name] = "ckeditor"
libraries[ckeditor][destination] = "libraries"
libraries[ckeditor][download][type] = "get"
libraries[ckeditor][download][url] = "http://download.cksource.com/CKEditor/CKEditor/CKEditor%204.2.2/ckeditor_4.2.2_standard.tar.gz"
libraries[flexslider][directory_name] = "flexslider"
libraries[flexslider][destination] = "libraries"
libraries[flexslider][download][type] = "get"
libraries[flexslider][download][url] = "https://github.com/woothemes/FlexSlider/archive/master.tar.gz"

; Custom Install Profile
projects[createsite][type] = "profile"
projects[createsite][download][type] = "git"
projects[createsite][download][url] = "git://github.com/randull/createsite.git"
