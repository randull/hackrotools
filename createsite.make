core = 7.x
api = 2

; Drupal Core
projects[] = drupal

; Dev Modules
projects[advanced_help] = 1.x-dev
projects[backup_migrate] = 3.x-dev


; Prod Modules
projects[] = addressfield
projects[] = admin_menu
projects[] = admin_views
projects[] = adminimal_admin_menu
projects[] = better_exposed_filters
projects[] = better_formats
projects[] = block_class
projects[] = blockcache_alter
projects[] = blockreference
projects[] = breakpoints
projects[] = calendar
projects[] = charts
projects[] = ckeditor
projects[] = colorbox
projects[] = content_access
projects[] = context
projects[] = ctools
projects[] = date
projects[] = devel
projects[] = disqus
projects[] = ds


; Themes
projects[xtheme][type] = theme
projects[xtheme][version] = 2
projects[xtheme][download][type] = git
projects[xtheme][download][url] = http://git.drupal.org/project/xtheme.git
projects[xtheme][download][branch] = 7.x-2.x
projects[shiny][type] = theme
projects[shiny][version] = 1.7
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
libraries[flexslider][download][url] = "https://codeload.github.com/woothemes/FlexSlider/zip/version/2.2"
libraries[html5shiv][directory_name] = "html5shiv"
libraries[html5shiv][destination] = "libraries"
libraries[html5shiv][download][type] = "get"
libraries[html5shiv][download][url] = "https://github.com/fubhy/html5shiv/archive/master.zip"
libraries[matchmedia][directory_name] = "matchmedia"
libraries[matchmedia][destination] = "libraries"
libraries[matchmedia][download][type] = "get"
libraries[matchmedia][download][url] = "https://github.com/fubhy/matchmedia/archive/master.zip"
libraries[pie][directory_name] = "pie"
libraries[pie][destination] = "libraries"
libraries[pie][download][type] = "get"
libraries[pie][download][url] = "https://github.com/fubhy/pie/archive/master.zip"
libraries[placeholder][directory_name] = "placeholder"
libraries[placeholder][destination] = "libraries"
libraries[placeholder][download][type] = "get"
libraries[placeholder][download][url] = "https://github.com/jamesallardice/Placeholders.js/archive/master.zip"
libraries[plupload][directory_name] = "plupload"
libraries[plupload][destination] = "libraries"
libraries[plupload][download][type] = "get"
libraries[plupload][download][url] = "https://github.com/moxiecode/plupload/archive/v1.5.8.tar.gz"
libraries[respond][directory_name] = "respond"
libraries[respond][destination] = "libraries"
libraries[respond][download][type] = "get"
libraries[respond][download][url] = "https://github.com/fubhy/respond/archive/master.zip"
libraries[s3-php5-curl][directory_name] = "s3-php5-curl"
libraries[s3-php5-curl][destination] = "libraries"
libraries[s3-php5-curl][download][type] = "get"
libraries[s3-php5-curl][download][url] = "https://github.com/tpyo/amazon-s3-php-class/archive/master.zip"
libraries[selectivizr][directory_name] = "selectivizr"
libraries[selectivizr][destination] = "libraries"
libraries[selectivizr][download][type] = "get"
libraries[selectivizr][download][url] = "https://github.com/fubhy/selectivizr/archive/master.zip"
libraries[simplepie][directory_name] = "simplepie"
libraries[simplepie][destination] = "libraries"
libraries[simplepie][download][type] = "get"
libraries[simplepie][download][url] = "http://simplepie.org/downloads/simplepie_1.3.1.compiled.php"



; Custom Install Profile
projects[createsite][type] = "profile"
projects[createsite][download][type] = "git"
projects[createsite][download][url] = "git://github.com/randull/createsite.git"
