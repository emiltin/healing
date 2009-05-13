require 'healing'


class Healer < Healing
  
  def describe
    @cloud.describe :recurse => true
  end
  
  def install
    puts 'installing'
    #it seems ssh here doesn't work if we use ~ in the path?
    Healing.run_locally "rsync -e 'ssh -i #{@cloud.key_path}' -ar /Users/emiltin/Desktop/healing/ root@#{@addr}:/healing"
  end
  
  def set_cloud_uuid
    puts 'setting cloud uuid'
    Healing.run_locally "ssh -i #{@cloud.key_path} root@#{@addr} \"echo '#{@cloud.uuid}' > /healing/cloud_uuid\""
  end
  
  def start
    map
    provision
    install
    set_cloud_uuid
    heal
  end
  
  def heal
    map
    puts "\nHealing instance #{@addr}."
    install   #should only upload ideal.rb and recipes...
    Healing.run_locally "ssh -i #{@cloud.key_path} root@#{@addr} \"cd /healing && bin/heal-local\""
  end
  
  def provision
    @cloud.provision
  end
  
  def map
    @map =  Healing::Map.new @cloud unless @map
    @addr = @map.instances.first.address if @map.instances.any?     #should ssh to to all instances.....
  end
    
  def show
    map
    @map.show
  end

end
