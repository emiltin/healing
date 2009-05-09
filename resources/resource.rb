class Heal
  
   class Resource
  
    def initialize options={}      
      @options = defaults.merge(options)
      healer.current_cloud.add self
    end
  
    def run cmd
      result  = `#{cmd}`
      puts result unless result==''
    end
  
    def log msg
      puts msg
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
