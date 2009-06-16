
cloud :test do
  uuid '4jjkkjwr3jk22'
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  image 'ami-bf5eb9d6'
    
  cloud :app do
    uuid 'zx2238qxfvd'
    instances 1
    rubygem 'sqlite3-ruby'
    rails_app 'poolparty_example', :repo => 'git://github.com/emiltin/poolparty_example.git', :env => :development
  end
end
