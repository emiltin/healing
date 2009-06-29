
cloud :default do
  uuid 'nfgj38j2jxdgj'
  key '/Users/emiltin/.ec2/testpair'
  instances 1 

  mysql_ebs 'vol-4943a020'
  rails_app 'poolparty_example', :repo => 'git://github.com/emiltin/poolparty_example.git', :environment => :production
end

