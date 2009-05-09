class Heal
  
   class Resource
  
    def initialize options={}      
      @options = defaults.merge(options)
      @cloud = healer.current_cloud
      @cloud.add_resource self
    end
  
    def run cmd
      result  = `#{cmd}`
      puts result unless result==''
    end
  
    def defaults
      {}
    end
    
    def heal
    end
    
    def revert
    end
    
  end
end
