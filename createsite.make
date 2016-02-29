core = 7.x
api = 2

; Drupal Core
projects[] = drupal

; Dev Modules


; Prod Modules
projects[] = admin_menu


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


; Custom Install Profile
projects[createsite][type] = "profile"
projects[createsite][download][type] = "git"
projects[createsite][download][url] = "git://github.com/randull/createsite.git"
