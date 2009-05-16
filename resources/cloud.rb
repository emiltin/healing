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
      n.times { root.armed << self } if n>0
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

end



def cloud name, &block
  Healing::RootCloud.new( {:name=>name}, &block )
end
