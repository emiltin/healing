
cloud :test do
  uuid '4jjkkjwr3jk22'
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  image 'ami-bf5eb9d6'
  instances 1

  recipe 'motd', :message => 'Welcome'
  
  #volume 'vol-4943a020'
  rubygem 'sqlite3-ruby'
  rubygem 'mysql'
  
  mysql_ebs 'vol-4943a020'
  rails_app 'poolparty_example', :repo => 'git://github.com/emiltin/poolparty_example.git', :environment => :production
end
