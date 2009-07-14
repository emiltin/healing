
cloud :dev do
  uuid 'hjujj3j'
  key '/Users/emiltin/.ec2/testpair'
  instances 1
  
  #10.times { failer }
  #volume 'vol-4943a020'
  mysql_ebs 'vol-4943a020'
  rails_app '/railsapp', :repo => 'git://github.com/emiltin/poolparty_example.git'
end


