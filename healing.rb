require 'resources/resource.rb'
require 'resources/file.rb'
require 'resources/dir.rb'
require 'resources/package.rb'
require 'resources/cloud.rb'
require 'providers/ec2_provider.rb'
require 'nodes/node.rb'
require 'local.rb'


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
  
  def load_addresses
    @addr = "ec2-174-129-95-238.compute-1.amazonaws.com"    #should get from cloud provider (ec2)
  end
  
  def describe
    load
    @cloud.describe :recurse => true
  end
  
  def install
    puts 'installing'
    #it seems ssh here doesn't work if we use ~ in the path?
    Healing.run_locally "rsync -e 'ssh -i #{@cloud.key}' -ar /Users/emiltin/Desktop/healing/ root@#{@addr}:/healing"
  end
  
  def set_cloud_uuid
    puts 'setting cloud uuid'
    Healing.run_locally "ssh -i #{@cloud.key} root@#{@addr} \"echo '#{@cloud.uuid}' > /healing/cloud_uuid\""
  end
  
  
  def start
    load
    load_addresses
    install
    set_cloud_uuid
    heal
  end
  
  def heal
    load
    load_addresses
    install   #should only upload ideal.rb and recipes...
    puts `ssh -i #{@cloud.key} root@#{@addr} "cd /healing && bin/heal-local"`
  end

end


