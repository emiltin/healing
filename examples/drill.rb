
cloud :drill do
  uuid '3883cnn2nc3'
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  image 'ami-bf5eb9d6'
  instances 1
  
  #core
  dir '/test'
  file '/test/file', :content => 'once upon a time'
  line_in_file '/test/file', :content => 'fairies = 7'
  link '/test/file', '/test/fairies'
  execute 'print working dir', "pwd"
  package 'irb'
  rubygem 'mysql'
  git_repo "/myrepo", :url => 'http://xx.xx', :user => 'www-data', :group => 'www-data'
  service 'mysql' => :off
  service 'mysql' do
    on
    while_stopped do
      file 'setings_file', :content => '3483239'
    end
  end

  #volume
  volume 'vol-342423'

  #recipes
  recipe 'motd', :message => 'Welcome'
  recipe('wow', :path => 'nicepath') { file options.path }
  recipe 'pop' do
    file 'poppy'
  end
  
  #plugins
  rails_app 'myapp', :repo => '/my/app'
  mysql_ebs 'vol-234234'
  
end

