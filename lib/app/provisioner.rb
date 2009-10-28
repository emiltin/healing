module Healing
  module App
    class Provisioner

      def initialize root
        @root = root
      end
      
      def diagnose
      end
      
      def heal
        if arm
          launch
          bootstrap
        end
        arrange_volumes
      end
      
      def arm
        @armed = {}
        @root.clouds.each do |c|
          cur = c.my_instances.size   
          balance = c.options.num_instances ? c.options.num_instances - cur : 0
          @armed[c] = balance if balance>0
        end
        return @armed.any?
      end
      
      def launch
        @launched = []
        total = @armed.values.inject { |v,m| v+m }
        puts "Launching #{total} instance(s)."
        @armed.each_pair do |cloud,num|
          @launched.concat @root.remoter.launch(:num => num, :key => @root.key_name, :image => cloud.options.image, :availability_zone => cloud.options.availability_zone, :cloud => cloud, :cloud_uuid => cloud.options.uuid)
        end
        @root.map.add_instances @launched
        wait_for_instances
      end

      def wait_for_instances
        @root.remoter.wait_for_addresses @launched
        @root.remoter.wait_for_ping @launched        
      end
      
      def bootstrap
        App::Bootstrapper.new(@launched).bootstrap
      end

      def volumes
        #TODO this method is not pretty
        volumes = []
        @root.clouds.each do |cloud|
          if cloud.volumes.any?
            instances = cloud.my_instances
            raise "Can't attach volume to cloud without instances!" if instances.empty?
            raise "Can't attach volume to more that one instance!" if instances.size>1
            i = instances.first
            cloud.volumes.each { |v| volumes << {:volume_id => v.options.vol_id, :instance_id => i.id, :device => v.options.device} }
          end
        end
        volumes
      end

      def arrange_volumes
        @root.remoter.arrange_volumes volumes
        #wait_for_volumes
      end


    end
  end
end
