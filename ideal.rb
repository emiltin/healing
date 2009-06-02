#this is where we describe our cloud, so we can heal it

cloud :app do
  remoter :ec2
  key '/Users/emiltin/.ec2/testpair'
  image 'ami-bf5eb9d6'
  instances 1
  uuid 'gi48gjdj33'
  line_in_file '/etc/motd', :content => "Welcome to the #{@parent.name}/#{@parent.uuid} cloud!"
  execute "puts", "pwd" do
    run "pwd"
    puts ::File.read('/etc/motd')
  end
  
end

