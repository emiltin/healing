require 'resources/resource.rb'
require 'resources/file.rb'
require 'resources/dir.rb'
require 'resources/package.rb'
require 'resources/cloud.rb'
require 'providers/ec2_provider.rb'
require 'nodes/node.rb'
require 'local.rb'
require 'remote.rb'


class Healing

  def self.run_locally cmd
    result  = `#{cmd}`
    puts result unless result==''
  end
  
  def load
    return if @cloud
    require 'ideal.rb'
    @cloud = Healing::Cloud.root
    raise "No cloud defined in ideal.rb!" unless @cloud
  end

end


