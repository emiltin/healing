

class Healing
  
  class InstanceInfo
    
    attr_reader :id, :key, :address, :cloud_uuid
    
    def initialize info
      @id = info[:id]
      @key = info[:key]
      @address = info[:address]
    end
    
    def fetch_cloud_uuid root
      @cloud_uuid = Healing.run_locally("ssh -i #{root.key_path} root@#{@address} \"cat /healing/cloud_uuid\"", :quiet => true).strip
    end
    
    def to_yaml
      {:id => @id, :key => @key, :address => @address }
    end
  end
  
end
