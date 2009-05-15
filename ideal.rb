#this is where we describe our cloud, so we can heal it

cloud :test do
  instances 2
  provider :ec2
  image 'ami-bf5eb9d6'
  key '/Users/emiltin/.ec2/testpair'
  uuid 'bj4jejce35xx'
  
  dir '/tmp/healing'
  file '/etc/motd', :content => "Feeling good."

  cloud :database do
    instances 1
    uuid '59kj3jfj3j'

    file '/etc/motd', :content => "Welcome to this database instance."

    cloud :master do
      instances 1
      uuid '4uv33jd'
      file '/etc/motd', :content => "Master here!"
    end

    cloud :slave do
      instances 5
      uuid '8bnxxb3k'
      file '/etc/motd', :content => "Slave here!"
    end

  end


end

