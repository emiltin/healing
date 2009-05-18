
module Healing
  
  class Map
    
    include Threading
    
    attr_reader :instances
    
    def initialize cloud
      @cloud = cloud
      @instances = []
    end
    
    def rebuild
      puts_progress "Scanning cloud." do
        @instances = @cloud.root.provider.instances :key => @cloud.root.key_name, :state => :running
        @instances.each_in_thread do |i|
          i.cloud = @cloud
          i.fetch_cloud_uuid     #ssh to each instance and read the cloud_uuid file
        end
      end
    end
    
    def add instances
      @instances += instances
    end
    
    def show
      rebuild
      n = 20
      puts "#{'instance'.ljust(12)}\t#{'state'.ljust(n)}\t#{'cloud'.ljust(n)}\taddress" if @instances.any?
      @instances.each do |i|
        c = Cloud.clouds.find { |c| c.uuid==i.cloud_uuid }
        cloud_name = c ? "#{' '*c.depth}#{c.name}" : '-'
        puts "#{i.id.to_s.ljust(12)}\t#{i.state.to_s.ljust(n)}\t#{cloud_name.to_s.ljust(n)}\t#{i.address}"
      end
      puts 'No instances running.' if @instances.empty?
    end
    
    def instances_in_cloud uuid
      @instances.find_all { |i| i.cloud_uuid==uuid.to_s }
    end
  end

end
