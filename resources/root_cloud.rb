module Healing

  class RootCloud < Cloud

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
      #    install
      heal_remote
      puts ''
      puts 'Cloud started and healed. Feels good!'
    end

    def arm
      @armed = {}
      arm_subcloud
      @armed
    end

    def launch
      num = @armed.values.inject { |n,v| n+v }
      puts "Launching #{num} instance(s)."
      @launched = provider.launch :num => num, :key => key_name, :image => image
    end

    def organize
      puts 'Organizing.'
      unorganized = @launched.dup
      @armed.each_pair do |c,num|
        num.times { unorganized.shift.belong c }
      end
    end

    def bootstrap
      @launched.each do
      end
    end

    def install
      puts 'Uploading.'
      map.instances.each do |instance|
        #it seems ssh here doesn't work if we use ~ in the path?
        Healing::Healer.run_locally "rsync -e 'ssh -i #{key_path} -o StrictHostKeyChecking=no' -ar /Users/emiltin/Desktop/healing/ root@#{instance.address}:/healing"
      end
    end


    def heal_remote
      puts "Initiating healing."
      map.rebuild
      install
      puts "Healing instances."
      map.instances.each do |i|
        puts "\n"
        i.execute "cd /healing && bin/heal-local"
      end
    end

    def first_instances
      map.instances.first
    end

  end
end