core = 7.x
api = 2

; Drupal Core
projects[drupal][type] = core
projects[drupal][version] = 7.26
projects[drupal][download][type] = get
projects[drupal][download][url] = http://ftp.drupal.org/files/projects/drupal-7.26.tar.gz

; Modules

projects[] = admin_menu
projects[] = backup_migrate
projects[] = better_formats
projects[] = blockreference
projects[] = breakpoints
projects[] = ckeditor
projects[] = context
projects[] = ctools
projects[devel] = 1.x-dev
projects[] = ds
projects[] = ds_bootstrap_layouts
projects[] = entity
projects[] = features
projects[] = field_group
projects[] = flexslider
projects[] = fontyourface
projects[] = google_analytics
projects[] = imagecache_actions
projects[] = imce
projects[jquery_update] = 2.x-dev
projects[] = libraries
projects[] = link
projects[] = linkit
projects[] = menu_block
projects[] = menu_position
projects[] = metatag
projects[] = module_filter
projects[] = nodeformsettings
projects[] = nodereference_url
projects[] = pathauto
projects[] = pathologic
projects[] = picture
projects[] = prod_check
projects[] = profile2
projects[] = references
projects[] = security_review
projects[] = strongarm
projects[] = token
projects[] = views
projects[] = views_bulk_operations

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
