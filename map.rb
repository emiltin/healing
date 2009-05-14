
module Healing
  
  class Map
    
    attr_reader :instances
    
    def initialize cloud, provider
      @cloud = cloud
      @provider = provider
      @path = 'instances.yml'
      @instances = []
      load
      update
    end
    
    def load
      info = YAML.load_file @path if ::File.exists? @path
      info.each { |item| @instances << RemoteInstance.new(item) } if info
    end

    def save
      info = []
      @instances.each { |i| info << { :id => i.id, :cloud_uuid => i.cloud_uuid } }
      ::File.open( @path, "w") { |f| YAML.dump(info,f) }
    end
    
    def update
      puts 'Syncing cloud map.'
      old_instances = @instances.dup
      @instances = @provider.instances_with_key @cloud.key_name
      @instances.reject! { |i| i.state!='running' }
      
      updates = []
      @instances.each do |cur|
        old = old_instances.find { |old| cur.id==old.id }
        if old
          cur.cloud_uuid = old.cloud_uuid
        else
          cur.fetch_cloud_uuid @cloud
          updates << cur
        end
      end
      if updates.any?
        puts "Added #{updates.size} new instance(s) to cloud map."
        save
      end
    end
    
    def show
      puts "Cloud: #{@cloud.name}"
      puts "Key: #{@cloud.key_name}"
      n = 20
      puts "#{'instance id'.ljust(12)}\t#{'state'.ljust(n)}\t#{'cloud uuid'.ljust(n)}\taddress" if @instances.any?
      @instances.each do |i|
        puts "#{i.id.to_s.ljust(12)}\t#{i.state.to_s.ljust(n)}\t#{(i.cloud_uuid=='' ? '-' : i.cloud_uuid).to_s.ljust(n)}\t#{i.address}"
      end
      puts 'No instances running.' if @instances.empty?
    end
    
    def instances_in_cloud uuid
      @instances.find_all { |i| i.cloud_uuid==uuid.to_s }
    end
  end

end
