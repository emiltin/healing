class Heal
  class Cloud
    
    def initialize name
      @name = name
      @resources = []
      healer.current_cloud.add_resource self if healer.current_cloud
      @depth = healer.current_depth
    end

    def add_resource r
      @resources << r
    end
  
    def resources
      @resources
    end
  
    def set_instances i
      @instances = i
    end
  
    def heal
      log "cloud #{@name}", -1
      log "#{@instances} instances" if @instances
 #     raise "A cloud with resources must have some instances!" if @instances.empty? && @resources.any?
      @resources.each { |item| item.heal }
    end

    def log msg, level=0
      puts '  '*(@depth+1+level) + msg
    end

  end
end


def instances number
  healer.current_cloud.set_instances number
end
