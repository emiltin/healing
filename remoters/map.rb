# the idea with the map was to keep a map of all instances and volumes, both running and to-be-launched...

module Healing
  module Remoter
    
    class Map
      
      include Threading
      
      attr_accessor :launched
      
      def initialize root
        @root = root
        @instances = []
        @volumes = []
        @launched = []
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
      
      def remove_instances i
        @instances -= i
      end
      
      def update
        return if @fresh
        puts_progress "Scanning" do
          @instances = @root.remoter.instances :key => @root.key_name, :state => :running
          @instances.each_in_thread { |i| i.place @root }
        end
        @fresh = true
      end
      
      def update_volumes
        return if @volumes_fresh
        puts_progress("Scanning volumes") { @volumes = @root.remoter.volumes }
        @volumes_fresh = true
      end
      
         
    end
  end
end
