
cloud :default do
  uuid '68u2hcjcdjj3'
  key '/Users/emiltin/.ec2/testpair'
  instances 1  

  git_repo '/myapp', :url => 'git://github.com/emiltin/poolparty_example.git'
    
  run 'choose db package', :description => "read rails config and install the right db package" do
    config = YAML.load_file('/myapp/config/database.yml') 
    env = :production
    adapter = config[env.to_s]['adapter']
    mappings = { 'mysql' => 'mysql', 'sqlite3' => 'sqlite3-ruby' }
    gem_name = mappings[ adapter ]
    print "Inspecting the rails config...  "
    if gem_name
      puts "using db adapter '#{adapter}'"
      run_recipe { rubygem gem_name }
    else
      puts "unkown db adater!"
    end
  end
  
end

