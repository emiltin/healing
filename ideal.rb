#this is where we describe our cloud, so we can heal it

cloud :test do
  provider :ec2
  image 'ami-bf5eb9d6'
  key '/Users/emiltin/.ec2/testpair'
  uuid '23c3niyj34v'
  instances 1
  
  
  #a passenger recipe:
  recipe 'passenger'

#  package 'mysql-server'
#  package 'git-core'
  #file '/etc/motd', :content => "Feeling good."
  
end

