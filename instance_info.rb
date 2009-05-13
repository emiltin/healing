

class Healing
  
  class InstanceInfo
    
    attr_accessor :cloud_uuid
    attr_reader :id, :key, :address, :state
    
    def initialize info
      @id = info[:id]
      @key = info[:key]
      @address = info[:address]
      @cloud_uuid = info[:cloud_uuid]
      @state = info[:state]
    end
    
    def fetch_cloud_uuid root
      @cloud_uuid = Healing.run_locally("ssh -i #{root.key_path} root@#{@address} \"cat #{CLOUD_UUID_PATH}\"", :quiet => true).strip
    end

  end
  
end
