
cloud :dev do
  uuid 'hjujj3j'
  key '/Users/emiltin/.ec2/testpair'
  
  dir '/xx'

  cloud :app do
    instances 10
    uuid '3jfjfkj3kr'
    dir '/xx/app'
  end
  
  cloud :db do
    uuid 'dlfkjl3rddd3333'
    instances 1
    dir '/xx/db'
  end

end


