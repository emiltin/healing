module Healing

  class RootCloud < Cloud

    include Threading

    attr_accessor :provider, :image, :instances, :armed

    def initialize options, &block
      raise "You can only define one root cloud!" if Cloud.root
      Cloud.root = self
      super( {:name => options[:name], :root => self}, &block )
      validate
      @instances = []
    end  

    def provider
      @provider
    end

    def image
      @image
    end

    def describe_settings
      super
      log "key: #{key_path}"
      log "instances: #{@num_instances}"
      log "provider: #{@provider.name}"
    end

    def validate
      super
      raise "You must specify a provider in the root cloud!" unless @provider
      raise "You must specify an image in the root cloud!" unless @image
    end

    def root?
      true
    end

    def terminate
      puts "Terminating cloud '#{name}'"
      #our map only includes running instances, but we also want to terminate pending instances
      list = provider.instances(:key => key_name).select { |i| i.state=='pending' || i.state=='running' }
      if list.any?
        provider.terminate list
      else
        puts "No instances running"
      end
    end

    def start
      rescan
      arm
      if @armed.any?
        launch
        bootstrap
        organize
      end
      install
    end

    def arm
      @armed = []
      @pruning = []
      super
    end

    def launch
      puts "Launching #{armed.size} instance(s)."
      @launched = provider.launch :num => armed.size, :key => key_name, :image => image
      @launched.each { |i| i.cloud=self }
      @instances += @launched
    end

    def organize
      unorganized = @launched.dup
      @armed.each_in_thread("Organizing") { |c| unorganized.shift.belong c }
      @armed = []
    end

    def bootstrap
      #after launching an instance, ruby might not be installed, so we need to manually bootstrap a minimal environment
      installer = "apt-get"   #should be determined from the os launched. how?
      @instances.each_in_thread "Bootstrapping" do |i|
        i.command "#{installer} update"
        i.command "#{installer} install ruby -y"
        
        #these items could be installed by healing?
        i.command "#{installer} install libreadline-ruby1.8 libruby1.8 ruby1.8-dev ruby1.8 rubygems -y"    #dev version is needed for building some gems, like passenger
        i.command "echo 'export PATH=$PATH:/var/lib/gems/1.8/bin' >> /etc/profile"
        i.command "mkdir /healing"
        i.execute
        #at this point we could upload healing and use it to install packages etc.
  #      i.command "gem source --add http://gems.github.com"
        #what else is needed?
      end
    end

    def install
      @instances.each_in_thread "Uploading" do |instance|
        #it seems ssh here doesn't work if we use ~ in the path?
        Healing::Healer.run_locally "rsync -e 'ssh -i #{key_path} -o StrictHostKeyChecking=no' -ar /Users/emiltin/Desktop/healing/ root@#{instance.address}:/healing", :quiet => true
        #TODO how to handle ssh/rsync error messages?
      end
    end

    def heal_remote
 #     prune
      start
      @instances.each_in_thread "Healing #{@instances.size} instance(s)" do |i|
        i.execute "cd /healing && bin/heal-local"
      end
      puts "Ahh!"
    end
      
    def first_instances
      @instances.first
    end
    
    def rescan
      scan unless @instances.any?
    end
    
    def scan
      puts_progress "Scanning" do
        @instances = provider.instances :key => key_name, :state => :running
        @instances.each_in_thread nil, :dot => nil do |i|
          i.cloud = self
          i.fetch_cloud_uuid     #ssh to each instance and read the cloud_uuid file
        end
      end
    end
    
    def show_instances
      rescan
      n = 20
      puts "#{'instance'.ljust(12)}\t#{'state'.ljust(n)}\t#{'cloud'.ljust(n)}\taddress" if @instances.any?
      @instances.each do |i|
        c = Cloud.clouds.find { |c| c.uuid==i.cloud_uuid }
        cloud_name = c ? "#{' '*c.depth}#{c.name}" : '-'
        puts "#{i.id.to_s.ljust(12)}\t#{i.state.to_s.ljust(n)}\t#{cloud_name.to_s.ljust(n)}\t#{i.address}"
      end
      puts 'No instances running.' if @instances.empty?
    end
    
    def prune
      rescan
      pruning = []
      pruning = super
      if pruning.any?
        puts "Pruning #{pruning.size} instance(s)."
        provider.terminate pruning
        @instances -= pruning        
      else
  #      puts "No pruning needed."
      end
    end
    
  end
end