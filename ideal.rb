#this is where we describe our cloud, so we can heal it

cloud :test do
  instances 15
  provider :ec2
  image 'ami-bf5eb9d6'
  key '/Users/emiltin/.ec2/testpair'
  uuid 'bj4jejce35xx'
  file '/etc/motd', :content => "Feeling good."
end

