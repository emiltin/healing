require 'healing'

class Healing
  
  class Worker
    
    def initialize
    end
    
    def save_cloud_uuid uuid
      path = '/healing/cloud_uuid'
      raise "Cloud uuid file already exists at #{path}!" if ::File.exist?(path)
      `echo '#{uuid}' > #{path}`
      @uuid = uuid
    end
    
    def load_cloud_uuid
      path = '/healing/cloud_uuid'
      raise "Cloud uuid file not found at #{path}!" unless ::File.exist?(path)
      @uuid = ::File.read(path).strip
    end
    
    def heal
      raise "This node has no cloud uuid yet!" unless @uuid
      require 'clouds.rb'
      cloud = Healing::Cloud.find_cloud_with_uuid @uuid
      if cloud
        puts "Healing started."
        cloud.heal
      else
        raise "No cloud found matching the uuid (#{@uuid.inspect}) of of this node!"
      end
      puts "Healing complete."
    end
    
  end
  
end
