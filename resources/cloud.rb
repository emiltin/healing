module Healing
  class Cloud < Resource
    
    attr_accessor :resources, :uuid, :name, :depth, :subclouds, :instances, :provider, :image
    
    class << self
      attr_accessor :root
    end
    
    @@clouds = []
    def self.clouds
      @@clouds
    end
    
    def initialize name, parent, &block
      raise "Clouds must be created with a block!" unless block
      @parent = parent
      @name = name
      @resources = []
      @subclouds = []
      @depth = @parent ? @parent.depth+1 : 0
      Lingo.new(self).instance_eval &block
      raise "Cloud uuid not set in '#{name}'" unless @uuid
      unless parent
        raise "You can only define one root cloud!" if Cloud.root
        Cloud.root = self
        raise "You must specify a provider in the root cloud!" unless @provider
        raise "You must specify an image in the root cloud!" unless @image
      end
      Cloud.clouds << self  
    end
    
    def describe options={}
      log "cloud: #{@name}", -1
      log "uuid: #{@uuid}"
      log "key: #{@key}" if key_path
      log "instances: #{@instances}" if @instances
      log "provider: #{@provider}" if @provider
      @resources.each { |item| item.describe options }
      @subclouds.each { |item| item.describe options } if options[:recurse]
    end
    
    def provider
      @parent ? @parent.provider : @provider
    end
    
    def image
      @parent ? @parent.image : @image
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
      raise "A cloud with resources must have some instances!" if @instances==nil && @resources.any?
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
        @cloud.instances = number
      end
      
      def image i
        @cloud.image = i
      end
      
      def provider p
        @cloud.provider = p
      end
      
      def uuid u
        @cloud.uuid = u.to_s
      end
    
      def cloud name, &block
        @cloud.subclouds << Cloud.new(name, @cloud, &block)
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
  Healing::Cloud.new(name, nil, &block)
end
