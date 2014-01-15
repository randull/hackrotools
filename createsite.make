core = 7.x
api = 2

; Drupal Core
projects[drupal][type] = core
projects[drupal][version] = 7.25
projects[drupal][download][type] = get
projects[drupal][download][url] = http://ftp.drupal.org/files/projects/drupal-7.25.tar.gz

; Modules
projects[] = admin_menu
projects[] = breakpoints
projects[] = ckeditor
projects[] = context
projects[] = ctools
projects[] = devel
projects[] = features
projects[] = flexslider
projects[] = libraries
projects[] = module_filter
projects[] = picture
projects[] = prod_check
projects[] = security_review
projects[] = strongarm
projects[] = views

; Themes
projects[omega][type] = theme
projects[omega][version] = 4
projects[omega][download][type] = git
projects[omega][download][url] = http://git.drupal.org/project/omega.git
projects[omega][download][branch] = 7.x-4.x
projects[rubik][type] = theme
projects[rubik][version] = 4
projects[rubik][download][type] = git
projects[rubik][download][url] = http://git.drupal.org/project/rubik.git
projects[rubik][download][branch] = 7.x-4.x
projects[tao][type] = theme
projects[tao][version] = 3
projects[tao][download][type] = git
projects[tao][download][url] = http://git.drupal.org/project/tao.git
projects[tao][download][branch] = 7.x-3.x

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
