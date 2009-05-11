#this is where we describe our cloud, so we can heal it

cloud :test do
  uuid '1vd74jvj3j3'
  key '/Users/emiltin/.ec2/testpair'
  instances 1
  
  file '/etc/motd', :content => "Welcome to your node in the 'test' cloud."
end
