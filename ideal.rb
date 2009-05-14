#this is where we describe our cloud, so we can heal it

cloud :test do
  instances 1
  provider :ec2
  image 'ami-bf5eb9d6'
  key '/Users/emiltin/.ec2/testpair'
  uuid '1vd74jvj3j3'
  
  dir '/tmp/healing'
  file '/etc/motd', :content => "Welcome to your healthy instance!"
end
