core = 7.x
api = 2

; Drupal Core
projects[] = drupal

; Dev Modules
projects[backup_migrate] = 3.x-dev
projects[features] = 2.x-dev
projects[jquery_update] = 2.x-dev

; Prod Modules
projects[] = admin_menu
projects[] = backup_migrate_files
projects[] = better_formats
projects[] = blockreference
projects[] = breakpoints
projects[] = calendar
projects[] = ckeditor
projects[] = colorbox
projects[] = context
projects[] = ctools
projects[] = date
projects[] = devel
projects[] = ds
projects[] = entity
projects[] = entityreference
projects[] = features_extra
projects[] = field_group
projects[] = flexslider
projects[] = fontyourface
projects[] = google_analytics
projects[] = imagecache_actions
projects[] = imce
projects[] = imce_plupload
projects[] = inline_entity_form
projects[] = job_scheduler
projects[] = libraries
projects[] = link
projects[] = linkit
projects[] = media
projects[] = menu_block
projects[] = menu_position
projects[] = metatag
projects[] = module_filter
projects[] = nodeformsettings
projects[] = nodequeue
projects[] = nodereference_url
projects[] = pathauto
projects[] = pathologic
projects[] = picture
projects[] = plupload
projects[] = prod_check
projects[] = references
projects[] = security_review
projects[] = services
projects[] = strongarm
projects[] = token
projects[] = uuid
projects[] = uuid_features
projects[] = views
projects[] = views_bulk_operations

; Themes
projects[omega][type] = theme
projects[omega][version] = 4.2
projects[omega][download][type] = git
projects[omega][download][url] = http://git.drupal.org/project/omega.git
projects[omega][download][branch] = 7.x-4.x
projects[shiny][type] = theme
projects[shiny][version] = 1.4
projects[shiny][download][type] = git
projects[shiny][download][url] = http://git.drupal.org/project/shiny.git
projects[shiny][download][branch] = 7.x-1.x

; Libraries
libraries[ckeditor][directory_name] = "ckeditor"
libraries[ckeditor][destination] = "libraries"
libraries[ckeditor][download][type] = "get"
libraries[ckeditor][download][url] = "http://download.cksource.com/CKEditor/CKEditor/CKEditor%204.2.2/ckeditor_4.2.2_standard.tar.gz"
libraries[colorbox][directory_name] = "colorbox"
libraries[colorbox][destination] = "libraries"
libraries[colorbox][download][type] = "get"
libraries[colorbox][download][url] = "https://github.com/jackmoore/colorbox/archive/master.tar.gz"
libraries[flexslider][directory_name] = "flexslider"
libraries[flexslider][destination] = "libraries"
libraries[flexslider][download][type] = "get"
libraries[flexslider][download][url] = "https://github.com/woothemes/FlexSlider/archive/master.tar.gz"
libraries[plupload][directory_name] = "plupload"
libraries[plupload][destination] = "libraries"
libraries[plupload][download][type] = "get"
libraries[plupload][download][url] = "https://github.com/moxiecode/plupload/archive/v1.5.8.tar.gz"


; Custom Install Profile
projects[createsite][type] = "profile"
projects[createsite][download][type] = "git"
projects[createsite][download][url] = "git://github.com/randull/createsite.git"
