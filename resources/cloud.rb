module Healing
  class Cloud < Resource

    attr_accessor :resources, :uuid, :name, :depth, :subclouds, :num_instances, :root

    class << self
      attr_accessor :root
    end

    @@clouds = []
    def self.clouds
      @@clouds
    end

    def initialize options, &block
      raise "Clouds must be created with a block!" unless block
      @root = options[:root]
      @parent = options[:parent]
      @name = options[:name]
      @resources = []
      @subclouds = []
      @depth = @parent ? @parent.depth+1 : 0
      Lingo.new(self).instance_eval &block
      validate
      Cloud.clouds << self 
    end
    
    def arm_subcloud
      cur = root.map.instances.select { |i| i.cloud_uuid==@uuid }.size   
      n = @num_instances - cur
      root.armed[self] = n if n>0
      @subclouds.each { |c| c.arm_subcloud } 
    end
    
    def num_instances_to_launch
      cur = root.map.instances.select { |i| i.cloud_uuid==@cloud_uuid }.size   
      n = @num_instances - cur
      n = 0 if n<0
      @subclouds.each { |c| n += c.num_instances_to_launch }
      n 
    end
    
    def instance
      @map.instances
    end
    
    def validate
      raise "Cloud uuid not set in '#{name}'" unless @uuid
    end

    def root?
      false
    end

    def launch
      ideal = num_instances
      cur = root.map.select { |i| i.cloud_uuid == cloud_uuid }.size
      instances = []
      if ideal>cur
        num = ideal - cur
        puts "Launching #{num} instance(s) in cloud #{name}."
        instances = launch_instances num
      end
      @subclouds.each { |c| instances << c.launch }    #traverse cloud hierachy
      instances
    end
    
    def organize
      num = num_instances_to_launch
      if num>0
      end
    end
    
    def describe options={}
      log "cloud: #{@name}", -1
      describe_settings
      @resources.each { |item| item.describe options }
      @subclouds.each { |item| item.describe options } if options[:recurse]
    end
    
    def describe_settings
      log "uuid: #{@uuid}"
    end
    
    def provider
      root.provider
    end

    def image
      root.image
    end

    def self.find_cloud_with_uuid uuid
      @@clouds.find { |c| c.uuid==uuid }
    end

    def key= key
      raise "Error in cloud '#{@name}': The key can only be set in the root cloud!" unless @depth==0
      @key = key
    end

    def key_name
      ::File.basename @key, ".*"
    end

    def key_path
      @key
    end

    def heal
      log "cloud: #{@name}", -1
      @resources.each { |item| item.heal }
    end

    def log msg, level=0
      puts '   '*(@depth+1+level) + msg
    end

    def get_uuid
      @uuid
    end

    class Lingo
      def initialize cloud
        @cloud = cloud
      end

      def instances number
        @cloud.num_instances = number
      end

      def image i
        @cloud.image = i
      end

      def provider p
        @cloud.provider = Healing::Provider::Base.build p
      end

      def uuid u
        @cloud.uuid = u.to_s
      end

      def cloud name, &block
        @cloud.subclouds << Cloud.new( {:name=>name, :root => @cloud.root, :parent => @cloud}, &block)
      end

      def file path, options={}
        @cloud.resources << Healing::File.new(path, @cloud, options)
      end

      def dir path, options={}
        @cloud.resources << Healing::Dir.new(path, @cloud, options)
      end

      def recipe path
        instance_eval ::File.read("recipes/#{path}.rb")
      end

      def key path
        @cloud.key = path
      end
    end

  end

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
        Healing::Healer.run_locally "rsync -e 'ssh -i #{key_path}' -ar /Users/emiltin/Desktop/healing/ root@#{instance.address}:/healing"
      end
    end
    

    def heal_remote
      puts "Healing started."
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



def cloud name, &block
  Healing::RootCloud.new( {:name=>name}, &block )
end
