class Heal
  class Cloud < Resource
    
    attr_reader :depth
    
    def initialize name, parent, &block
      @parent = parent
      @name = name
      @resources = []
      @depth = parent ? @parent.depth+1 : 0
      instance_eval &block
    end

    def heal
      log "cloud: #{@name}", -1
      log "instances: #{@instances}" if @instances
 #     raise "A cloud with resources must have some instances!" if @instances.empty? && @resources.any?
      @resources.each { |item| item.heal }
    end

    def log msg, level=0
      puts '   '*(@depth+1+level) + msg
    end

    
    def cloud name, &block
      @resources << Heal::Cloud.new(name, self, &block)
    end
    
    def instances number
      @instances = number
    end

    def file path, options={}
      @resources << Heal::File.new(path, self, options)
    end
    
    def recipe path
      instance_eval ::File.read("recipes/#{path}.rb")
    end
  end
end


