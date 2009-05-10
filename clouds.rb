

cloud :test do
  uuid '5bdfg3sdt3'
  keypair '~/.ssh/testpair'
  instances 1
  
  file '/etc/motd', :content => "\n/////// Healing feels good! ////////\n"
  dir 'tmp/healing'
end
