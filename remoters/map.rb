# the idea with the map was to keep a map of all instances and volumes, both running and to-be-launched...

module Healing
  module Remoter
    
    class Map
      
      include Threading
      attr_accessor :launched
      
      def initialize root
        @root = root
        @instances = []
        @launched = []
        @volumes = []
      end
      
      def outdate!
        @fresh = false
      end
      
      def instances filter={}
        update
        @instances
      end
      
      def volumes filter={}
        update_volumes
        @volumes
      end
      
      def add_instances i
        @instances += i
      end
      
      def update
        return if @fresh
        puts_progress "Scanning" do
          @instances = @root.remoter.instances :key => @root.key_name, :state => :running
          @instances.each_in_thread nil, :dot => nil do |i|
            i.cloud = @root
            i.fetch_cloud_uuid     #ssh to each instance and read the cloud_uuid file
          end
        end
        @fresh = true
      end
      
      def update_volumes
        return if @volumes_fresh
        puts_progress("Scanning volumes") { @volumes = @root.remoter.volumes }
        @volumes_fresh = true
      end
      
      def provision
      end
      
      def launch
        root.arm
        armed = @instances.select { |i| i.state == :armed }
        if armed.any?
          puts "Launching #{armed.size} instance(s)."
          launched = remoter.launch :num => armed.size, :key => root.key_name, :image => root.image
          unorganized = launched.dup
          armed.each_in_thread("Organizing") { |c| armed.unorganized.shift.belong c }
          launched
        end
      end
        
    end
  end
end
