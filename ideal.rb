#this is where we describe our cloud, so we can heal it

cloud :test do
  provider :ec2
  key '/Users/emiltin/.ec2/testpair'
  
  image 'ami-bf5eb9d6'
  uuid 'nbxd3jjv33f'
  instances 1
  
  volume 'vol-4943a020' => '/vol'   #this only makes sense if there is exactly one instance in this cloud
  
  #recipe 'passenger'
=begin  
  package 'ruby1.8-dev'
  package 'rubygems'
  package 'xfsprogs'
  package 'apache2-mpm-prefork'
  package 'apache2-prefork-dev'
  package 'libapr1-dev'
  package 'mysql-server'
  package 'imagemagick'
  package 'libxml2'
  package 'libxml2-dev'
  package 'git-core'

  rubygem 'rails'
  rubygem 'passenger'
  rubygem 'libxml-ruby'
  rubygem 'uuidtools'
  rubygem 'ar_mailer'
  rubygem 'mysql'
  rubygem 'aws-s3'
  rubygem 'activemerchant'
=end

  file '/etc/motd', :content => "Feeling good."
end

