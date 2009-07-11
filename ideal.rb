
cloud :dev do
  uuid 'hjujj3j'
  key '/Users/emiltin/.ec2/testpair'
  
  instances 1  
  failer
  
  cloud :app do
    instances 2
    uuid '3jfjfkj3kr'
    failer
  end
  
end


