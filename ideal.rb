#this is where we describe our cloud, so we can heal it

cloud :test do
  instances 2
  provider :ec2
  image 'ami-bf5eb9d6'
  key '/Users/emiltin/.ec2/testpair'
  uuid '1vd74jvj3j3'
  
  dir '/tmp/healing'
  file '/etc/motd', :content => "Ahhh!"

  cloud :db do
    instances 1
    uuid '4abm39jdfn'

    file '/etc/motd', :content => "Database instances feeling good!"
  end
end
