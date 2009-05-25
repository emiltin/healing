module Healing
  class Cloud < Element

    attr_accessor :resources, :uuid, :name, :depth, :subclouds, :num_instances, :root, :volumes

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
      @volumes = {}
      @subclouds = []
      @depth = @parent ? @parent.depth+1 : 0
      Lingo.new(self).instance_eval &block
      validate
      Cloud.clouds << self 
    end
    
    def arm
      cur = root.instances.select { |i| i.cloud_uuid==@uuid }.size   
      n = @num_instances - cur
      n.times { root.armed << self } if n>0
      @subclouds.each { |c| c.arm } 
    end

    def prune
      pruning = []
      cur = root.instances.select { |i| i.cloud_uuid==@uuid }   
      n = cur.size - @num_instances
      n.times { pruning << cur.shift } if n>0   #pick instances to terminate
      @subclouds.each { |c| pruning.concat c.prune }
      pruning
    end
    
    def validate
      raise "Cloud uuid not set in '#{name}'" unless @uuid
    end

    def root?
      false
    end
    
    def describe options={}
      log "cloud: #{@name}", -1
      describe_settings
      @resources.each { |item| item.describe options }
      @subclouds.each { |item| item.describe options } if options[:recurse]
    end
    
    def describe_settings
      log "uuid: #{@uuid}"
      log "volumes: #{@volumes.inspect}" if @volumes.size>0
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

  end

end



def cloud name, &block
  Healing::RootCloud.new( {:name=>name}, &block )
end

def instance name, &block
  Healing::RootCloud.new( {:name=>name, :instances => 1}, &block )
end
