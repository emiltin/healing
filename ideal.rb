
cloud :test do
  uuid 'gi48gjdj33'
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  image 'ami-bf5eb9d6'
  
  file '/etc/motd', :content => 'this will be added to all instances.'

  cloud :db do
    uuid '4jjkkjwr3jk22'
    instances 1
    line_in_file '/etc/motd', :content => 'db cloud.'
    volume 'vol-4943a020'
    package 'mysql-server'
    service 'mysql'
  end

  cloud :app do
    uuid 'ckj3jjdd'
    instances 1
    line_in_file '/etc/motd', :content => 'app cloud.'
    package 'sqlite3'
    package 'libsqlite3-dev'
    rubygem 'sqlite3-ruby'
    rails_app 'poolparty_example', :repo => 'git://github.com/emiltin/poolparty_example.git', :env => :development
  end

end
