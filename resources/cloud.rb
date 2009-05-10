class Healing
  class Cloud < Resource
    
    attr_reader :name
    attr_reader :depth
    attr_reader :resources
    attr_reader :children
    
    @@clouds = []
        
    def self.clouds
      @@clouds
    end
    
    def initialize name, parent, &block
      @parent = parent
      @name = name
      @resources = []
      @depth = @parent ? @parent.depth+1 : 0
      @clouds = []
      instance_eval &block
      raise "Cloud uuid not set in '#{name}'" unless @uuid
      Cloud.clouds << self
    end
  
    def describe options={}
      log "cloud: #{@name}", -1
      log "uuid: #{@uuid}"
      log "keypair: #{@keypair}"
      log "instances: #{@instances}" if @instances
      log "-"
      @resources.each { |item| item.describe options } if options[:recurse]
    end
    
    def find_cloud uuid
      return self if @uuid==uuid.to_s
      @clouds.each do |item|
        cloud = item.find_cloud uuid
        return cloud if cloud
      end
      nil
    end
    
    def heal
      log "cloud: #{@name}", -1
 #     raise "A cloud with resources must have some instances!" if @instances.empty? && @resources.any?
      @resources.each { |item| item.heal }
    end

    def log msg, level=0
      puts '   '*(@depth+1+level) + msg
    end

    def get_uuid
      @uuid
    end
    
    def cloud name, &block
      @children << Healing::Cloud.new(name, self, &block)
    end
    
    def instances number
      @instances = number
    end
    
    def uuid u
      @uuid = u.to_s
    end
    
    def file path, options={}
      @resources << Healing::File.new(path, self, options)
    end

    def dir path, options={}
      @resources << Healing::Dir.new(path, self, options)
    end

    def recipe path
      instance_eval ::File.read("recipes/#{path}.rb")
    end
    
    def keypair path
      raise "Error in cloud '#{@name}': The keypair can only be set in the root cloud!" unless @depth==0
      @keypair = path
    end
    
  end
end



def cloud name, &block
  Healing::Cloud.new(name, nil, &block)
end
