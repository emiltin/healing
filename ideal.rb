#this is where we describe our cloud, so we can heal it

cloud :app do
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  uuid 'gi48gjdj33'
  image 'ami-bf5eb9d6'
  instances 1
  volume 'vol-4943a020'

  package 'mysql-server'

  rubygem 'rails'

  dir '/blabla'
  file '/etc/motd', :content => "Welcome"
  line_in_file '/etc/motd', :content => "Welcome to your #{@parent.name}/#{@parent.uuid} cloud!"

  service 'mysql'
end




=begin
#define different states
cloud :app => :enabled do
  service :mysql => :enabled
  service :passenger => :enabled
end

cloud :app, :state => :disabled do
  service :passenger => :disabled
  service :mysql => :disabled
end


#add virtual hosts - this would be a separate file
#reopen cloud and add some stuff...ª
require 'path/to/my/cloud.rb'
cloud :app do
  virtual_host 'app1'
end
=end