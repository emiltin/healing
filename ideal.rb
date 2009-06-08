
cloud :app do
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  uuid 'gi48gjdj33'
  image 'ami-bf5eb9d6'
  instances 1

#  volume 'vol-4943a020'
#  package 'mysql-server'
#  service 'mysql'
  recipe 'rails_app'
end
