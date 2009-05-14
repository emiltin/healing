

module Healing
  
  class RemoteInstance
    
    attr_accessor :cloud_uuid, :address
    attr_reader :id, :key, :state
    
    def initialize info
      @id = info[:id]
      @key = info[:key]
      @address = info[:address]
      @cloud_uuid = info[:cloud_uuid]
      @state = info[:state]
    end
    
    def fetch_cloud_uuid root
      @cloud_uuid = Healing::Healer.run_locally("ssh -i #{root.key_path} root@#{@address} \"cat #{CLOUD_UUID_PATH}\"", :quiet => true).strip
    end

    def send_cloud_uuid root
#      puts "setting cloud uuid on instance #{@address} to #{@cloud_uuid}"
      Healing::Healer.run_locally "ssh -i #{root.key_path} root@#{@address} \"mkdir /healing && echo '#{@cloud_uuid}' > /healing/cloud_uuid\""
    end

  end
  
end
