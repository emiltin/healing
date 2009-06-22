recipe 'passenger'

package 'sqlite3'
rubygem 'sqlite3-ruby'

git_repo '/poolparty_example', :url => 'git://github.com/emiltin/poolparty_example.git', :user => 'www-data', :group => 'www-data'

#remove default virtual host
file '/etc/apache2/sites-enabled/000-default', :remove => true
  
#add virtual host
file '/etc/apache2/sites-enabled/poolparty_example', :content => <<-EOF
<Directory "/poolparty_example">
 Options FollowSymLinks
 AllowOverride None
 Order allow,deny
 Allow from all
</Directory>

<VirtualHost *:80>
 ServerName localhost
 DocumentRoot /poolparty_example/public
 RailsEnv development
</VirtualHost>
EOF

service 'apache2' => :restart
