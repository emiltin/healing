require 'resources/resource.rb'
require 'resources/file.rb'
require 'resources/dir.rb'
require 'resources/package.rb'
require 'resources/cloud.rb'
require 'providers/provider.rb'
require 'providers/ec2.rb'
require 'instance_info.rb'
require 'instance.rb'
require 'healer.rb'
require 'map.rb'

CLOUD_UUID_PATH = '/healing/cloud_uuid'


class Healing
  
  def initialize
    load_ideal
  end
  
  def self.run_locally cmd, options={}
    result  = `#{cmd}`
    puts result unless result=='' || options[:quiet]
    result
  end
  
  def load_ideal
    return if @cloud
    require 'ideal.rb'
    @cloud = Healing::Cloud.root
    raise "No cloud defined in ideal.rb!" unless @cloud
  end

end


