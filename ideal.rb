
cloud :default do
  uuid '68u2hcjcdjj3'
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  image 'ami-bf5eb9d6'
  instances 1
  
  recipe 'motd', :message => 'Welcome'
end

