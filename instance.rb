require 'healing'


class Instance < Healing
    
  def initialize
    load_cloud_uuid
    super
    @cloud = Healing::Cloud.find_cloud_with_uuid @uuid
    raise "No cloud found matching the uuid (#{@uuid.inspect}) of of this instance!" unless @cloud
  end
    
  def save_cloud_uuid uuid
    raise "Cloud uuid file already exists at #{CLOUD_UUID_PATH}!" if ::File.exist?(CLOUD_UUID_PATH)
    Healing.run_locally "echo '#{uuid}' > #{CLOUD_UUID_PATH}"
    @uuid = uuid
  end
  
  def load_cloud_uuid
    raise "Cloud uuid file not found at #{CLOUD_UUID_PATH}!" unless ::File.exist?(CLOUD_UUID_PATH)
    @uuid = ::File.read(CLOUD_UUID_PATH).strip
    raise "This instance has no cloud uuid yet!" unless @uuid
  end
  
  def heal
    puts "Beginning to heal..."
    @cloud.heal
    puts "Healing complete. Ahhh!"
  end
  
end
