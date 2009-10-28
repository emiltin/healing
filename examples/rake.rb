
cloud :raking do
  uuid '68u2hcjcdjj3'
  key '/Users/emiltin/.ec2/testpair'
  instances 1
  
  mysql_ebs 'vol-4943a020'
  rails_app '/rails_app', :repo => 'git://github.com/emiltin/poolparty_example.git'
  rake "stats", :base => '/rails_app'#, :flags => "RAILS_ENV=production"
  rake "log:clear", :base => '/rails_app'
end

