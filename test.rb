require 'heal'


cloud :healing do  

  cloud :app do
    instances 2..3
    file 'app'
  end
  
  cloud :db do
    cloud :master do
      instances 1
      file 'master'
    end
    cloud :slave do
      instances 1
      file 'slave'
    end
  end

end


heal
