
cloud :raking do
  uuid '68u2hcjcdjj3'
  key '/Users/emiltin/.ec2/testpair'
  instances 1
  
  mysql_ebs 'vol-4943a020'
  rails_app '/poolparty_example', :repo => 'git://github.com/emiltin/poolparty_example.git', :environment => :production
#  rubygem 'rake'
  rake "stats", :base => '/poolparty_example'#, :flags => "RAILS_ENV=production"
  rake "log:clear", :base => '/poolparty_example'
end

