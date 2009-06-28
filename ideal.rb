
cloud :default do
  uuid '68u2hcjcdjj3'
  key '/Users/emiltin/.ec2/testpair'
  instances 1  
  
  dir '/xx'
  file '/xx/yy', :content => 'cool'
  recipe 'motd', :message => 'simsalabim'
end

