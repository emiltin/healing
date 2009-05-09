require 'heal'


cloud :app do  
  dir 'tmp'
  file 'tmp/1', :content => 'so much space!'
  
  cloud :db do
    dir 'db'
  end
end


heal
