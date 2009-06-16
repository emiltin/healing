
cloud :test do
  uuid '4jjkkjwr3jk22'
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  image 'ami-bf5eb9d6'
  instances 1
  volume 'vol-4943a020'

# rubygem 'sqlite3-ruby'
  recipe 'mysql-ebs'
  
  #rails_app 'poolparty_example', :repo => 'git://github.com/emiltin/poolparty_example.git', :env => :development
end
