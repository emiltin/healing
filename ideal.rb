
cloud :default do
  uuid '68u2hcjcdjj3'
  key '/Users/emiltin/.ec2/testpair'
  instances 1  

  rubygem 'mysql'
  mysql_ebs 'vol-4943a020'
  rails_app 'poolparty_example', :repo => 'git://github.com/emiltin/poolparty_example.git', 
                                 :environment => :production
  
end

