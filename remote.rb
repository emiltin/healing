require 'healing'


class RemoteHealing < Healing
  
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
    puts "\nHealing node #{@addr}."
    install   #should only upload ideal.rb and recipes...
    Healing.run_locally "ssh -i #{@cloud.key} root@#{@addr} \"cd /healing && bin/heal-local\""
  end


end
