module Healing

  class RootCloud < Cloud

    include Threading

    attr_accessor :provider, :image, :map, :armed

    def initialize options, &block
      raise "You can only define one root cloud!" if Cloud.root
      Cloud.root = self
      super( {:name => options[:name], :root => self}, &block )
      validate
      @map = Healing::Map.new @root
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
      map.rebuild
      if map.instances.any?
        provider.terminate map.instances
      else
        puts "No instances to terminate."
      end
    end

    def start
      map.rebuild
      if arm.any?
        launch
        organize
        bootstrap
      end
      heal_remote
    end

    def arm
      @armed = []
      arm_subcloud
      @armed
    end

    def launch
      puts "Launching #{armed.size} instance(s)."
      @launched = provider.launch :num => armed.size, :key => key_name, :image => image
    end

    def organize
      unorganized = @launched.dup
      puts_progress "Organizing" do
        @armed.each_in_thread do |c|
          unorganized.shift.belong c
        end
      end
      @armed = []
    end

    def bootstrap
      @launched.each_in_thread do
      end
    end

    def install
      puts_progress "Uploading" do
        map.instances.each_in_thread do |instance|
          #it seems ssh here doesn't work if we use ~ in the path?
          Healing::Healer.run_locally "rsync -e 'ssh -i #{key_path} -o StrictHostKeyChecking=no' -ar /Users/emiltin/Desktop/healing/ root@#{instance.address}:/healing"
        end
      end
    end

    def heal_remote
      map.rebuild
      install
      results = {}
      map.instances.each_in_thread "Healing #{map.instances.size} instances" do |i|
        results[i] = i.execute "cd /healing && bin/heal-local"
      end
      results.each_pair do |i,r|
        puts "--------------- #{i.address} ---------------".ljust(80,'-')
        puts r
      end
      puts '-'*80
    end

    def first_instances
      map.instances.first
    end

  end
end