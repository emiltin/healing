require 'resources/resource.rb'
require 'resources/file.rb'
require 'resources/dir.rb'
require 'resources/package.rb'
require 'resources/cloud.rb'
require 'ec2_provider.rb'
require 'worker.rb'




class Healing
  
  def load
    return if @cloud
    require 'ideal.rb'
    @cloud = Healing::Cloud.root
    raise "No cloud defined in ideal.rb!" unless @cloud
    @addr = "ec2-174-129-95-238.compute-1.amazonaws.com"    #should get from cloud provider (ec2)
  end
  
  def describe
    load
    @cloud.describe :recurse => true
  end
  
  def install
    puts 'installing'
    #it seems ssh here doesn't work if we use ~ in the path?
    puts `rsync -e 'ssh -i #{@cloud.key}' -ar /Users/emiltin/Desktop/healing/ root@#{@addr}:/healing`
  end
  
  def set_cloud_uuid
    puts 'setting cloud uuid'
    puts `ssh -i #{@cloud.key} root@#{@addr} "echo '#{@cloud.uuid}' > /healing/cloud_uuid"`
  end
  
  
  def start
    load
    install
    set_cloud_uuid
    heal
  end
  
  def heal
    load
    install   #should only upload ideal.rb and recipes...
    puts 'healing'
    puts `ssh -i #{@cloud.key} root@#{@addr} "cd /healing && bin/heal-worker"`
  end

end


