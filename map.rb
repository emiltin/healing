require 'healing'

class Healing
  
  class Map
    
    attr_reader :instances
    
    def initialize cloud
      @cloud = cloud
      @path = 'instances.yml'
      @instances = []
      load
      update
    end
    
    def load
      info = YAML.load_file @path if ::File.exists? @path
      info.each { |item| @instances << InstanceInfo.new(item) } if info
    end

    def save
      #info = [ { :id => 1, :cloud_uuid => '4jvjj232', :address => "ec2-324.34.34.34.com" } ]   #test
      info = []
      @instances.each { |i| info << i.to_yaml }
      ::File.open( @path, "w") { |f| YAML.dump(info,f) }
    end
    
    def update
      ec2 = Healing::EC2Provider.new
      currrent_instances = ec2.instances_with_key @cloud.key_name
      
      remove = []     #remove outdated info
      @instances.each do |old|
        remove << old unless currrent_instances.find { |cur| cur.id==old.id }
      end
      
      add = []        #add new info
      currrent_instances.each do |cur|
        unless @instances.find { |old| cur.id==old.id }
          cur.fetch_cloud_uuid @cloud
          add << cur
        end
      end
      
      if remove.any? || add.any?
        @instances -= remove
        @instances += add
        puts "Updated cloud map: #{remove.size} outdated, #{add.size} new."
        save
      else
        puts 'Cloud map up-to-date.'
      end
    end
        
    def show
      puts "Cloud: #{@cloud.name}"
      puts "Key: #{@cloud.key_name}"
      @instances.each do |i|
        puts "#{i.id}\t#{i.address}\t#{i.cloud_uuid}"
      end
    end
  end

end
