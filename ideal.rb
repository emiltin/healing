#this is where we describe our cloud, so we can heal it

cloud :test do
  uuid '1vd74jvj3j3'
  key '/Users/emiltin/.ec2/testpair'
  instances 1
  
  dir '/tmp/healing'
  file '/etc/motd', :content => "Welcome to your your healing instance!"
end
