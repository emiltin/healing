module Healing
  module Structure
    class Provisioner

      def initialize root
        @root = root
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
          balance = c.num_instances ? c.num_instances - cur : 0
          @armed[c] = balance if balance>0
        end
        return @armed.any?
      end
      
      def launch
        @launched = []
        total = @armed.values.inject { |v,m| v+m }
        puts "Launching #{total} instance(s)."
        @armed.each_pair do |cloud,num|
          @launched.concat @root.remoter.launch(:num => num, :key => @root.key_name, :image => cloud.image, :cloud => cloud, :cloud_uuid => cloud.uuid)
        end
        @root.map.add_instances @launched
        wait_for_instances
      end

      def wait_for_instances
        @root.remoter.wait_for_addresses @launched
        @root.remoter.wait_for_ping @launched        
      end
      
      def bootstrap
        #after launching an instance, ruby might not be installed, so we need to manually bootstrap a minimal environment
        installer = "apt-get"   #should be determined from the os launched. how?
        @launched.each_in_thread "Bootstrapping" do |i|
          i.command "mkdir /healing"
          i.command "echo '#{i.cloud_uuid}' > #{CLOUD_UUID_PATH}"
          i.command "#{installer} update"
          #i.command "#{installer} upgrade"
          i.command "#{installer} install ruby libreadline-ruby1.8 libruby1.8 ruby1.8-dev ruby1.8 rubygems -y"    #dev version is needed for building some gems, like passenger
          i.command "echo 'export PATH=$PATH:/var/lib/gems/1.8/bin' >> /etc/profile"
          i.execute
          
          #at this point we could upload healing and use it to install packages etc.
          #      i.command "gem source --add http://gems.github.com"
          #what else is needed?
        end
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
            cloud.volumes.each { |v| volumes << {:volume_id => v.id, :instance_id => i.id, :device => v.device} }
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
