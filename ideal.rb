#this is where we describe our cloud, so we can heal it

cloud :app do
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  image 'ami-bf5eb9d6'
  
  cloud :web do
    uuid '5jo5ncnck223x'
    instances 2
    file '/etc/motd', :content => "Feeling good."
    recipe 'passenger'
  end
    
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
  
  cloud :db do
    instance :master do
      uuid 'gi48gjdj33'
      volume 'vol-4943a020', :device => '/dev/sdh'   #this only makes sense if there is exactly one instance in this cloud
    end
    instance :slave do
      uuid '4jbvj3jd'
      volume 'vol-01698468', :device => '/dev/sdh'   #this only makes sense if there is exactly one instance in this cloud
    end
  end
end

