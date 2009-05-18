#this is where we describe our cloud, so we can heal it

cloud :test do
  instances 1
  provider :ec2
  image 'ami-bf5eb9d6'
  key '/Users/emiltin/.ec2/testpair'
  uuid '23c3niyj34v'
#  file '/etc/motd', :content => "Feeling good."
  #package 'irb'
  package 'mysql-server'
  package 'rubygems'
  rubygem 'rails'
end

