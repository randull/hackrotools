<p><h3>Preparesite:</h3>
Creates Apache Config, DB & DB User, and empty directory within /var/www on Dev and Prod<br>
<i>preparesite <strong>domain.tld "Site Name"</strong></i></p>
<p><h3>Generatesite:</h3>
Creates Apache Config, DB & DB User, and empty directory within /var/www on Dev and Prod<br>
Also Generates Drupal site using custom Installation Profile on Dev & Clones it to Prod<br>
<i>generatesite <strong>domain.tld "Site Name"</strong></i></p>
<p><h3>Updatesite:</h3>
Clones current site from Prod to Dev, to be used before testing Drupal updates on Dev<br>
<i>updatesite <strong>domain.tld</strong></i></p>
<p><h3>Stagesite:</h3>
Pushes changes done on Dev to Github repo, then pulls those changes to Prod<br>
<i>stagesite <strong>domain.tld "Git Commit Comments"</strong></i></p>
<p><h3>Migratesite:</h3>
Migrates entire site from Dev to Prod, will overwrite everything including DB<br>
<i>migratesite <strong>domain.tld "Git Commit Comments"</strong></i></p>
<p><h3>Cleansite:</h3>
Fixes Drupal file permissions, removes unnecessary placeholder files<br>
<i>cleansite <strong>domain.tld</strong></i></p>
<p><h3>Emptysite:</h3>
Drops all tables in Database, deletes all files and directories in root directory<br>
<i>emptysite <strong>domain.tld</strong></i></p>
<p><h3>Removesite:</h3>
Deletes DB and DB user, removes entire directory from /var/www, Apache config, All of it!
<i>removesite <strong>domain.tld</strong></i><br></p>
