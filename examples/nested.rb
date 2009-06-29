
cloud :master_slave do
  uuid '68u2hcjcdjj3'
  key '/Users/emiltin/.ec2/testpair'
  
  dir '/xx'
  
  cloud :app do
    uuid  'vmcfncnagagnc344'
    instances 3 
    dir '/xx/yy'
    rails_app 'poolparty_example', :repo => 'git://github.com/emiltin/poolparty_example.git', :environment => :production
  end

  cloud :db do
    instance :master do
      uuid  '0vhjj348isjsj3fb'
      dir '/xx/zz'
      mysql_ebs 'vol-4943a020'
    end
    instance :slave do
      uuid  '7877vjujxhhfd2h'
      dir '/xx/ww'
      package 'mysql-client'
      package 'mysql-server'
    end
  end
  
end

