module Healing
  
   class Resource
  
    def initialize cloud, options={}     
      @cloud = cloud 
      @options = defaults.merge(options)
    end
  
    def defaults
      {}
    end
    
    def heal
    end
    
    def revert
    end
    
    def log msg
      @cloud.log msg
    end
    
  end
end
