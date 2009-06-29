module Healing
  module Structure
    class Root < Cloud

      include Healing::Threading

      attr_accessor :remoter, :map, :armed, :clouds
      
      def initialize o, &block
        raise "You can only define one root cloud!" if Cloud.root
        Cloud.root = self
        @clouds = []
        @root = self
        super  nil, o, &block
        @map = Remoter::Map.new self
        build_remoter
      end  
      
      def build_remoter
        @remoter = Healing::Remoter::Base.build options.remoter
      end
            
      def compile
        super
      end

      def preflight_root
        @clouds.each do |c|
          c.preflight
        end
      end
      
      def remoter
        @remoter
      end

      def describe_settings
        super
        puts_setting :key, options.key
        puts_setting :image, options.image
        puts_setting :remoter, options.remoter
      end

      def validate
        super
        raise "You must specify a remoter in the root cloud!" unless options.remoter
        raise "You must specify an image in the root cloud!" unless options.image
      end

      def root?
        true
      end

      def terminate
        puts "Terminating cloud '#{options.name}'"
        #our map only includes running instances, but we also want to terminate pending instances
        list = remoter.instances(:key => key_name).select { |i| i.state=='pending' || i.state=='running' }
        if list.any?
          remoter.terminate list
        else
          puts "No instances running."
        end
      end

      def install
        map.instances.each_in_thread "Uploading" do |instance|
          #it seems ssh here doesn't work if we use ~ in the path?
          Healing::App::Base.run_locally "rsync -e 'ssh -i #{options.key} -o StrictHostKeyChecking=no' -ar /Users/emiltin/Desktop/healing/ root@#{instance.address}:/healing", :quiet => true
          #TODO how to handle ssh/rsync error messages?
        end
      end
            
      def heal_remote
        App::Provisioner.new(self).heal
        install
        map.instances.each_in_thread "Healing #{map.instances.size} instance(s)" do |i|
          i.execute("cd /healing && bin/heal-local")
        end
        puts "Ahh!"
      end

      def show_instances
        list = map.instances.dup.select { |i| Cloud.clouds.find { |c| c.options.uuid==i.cloud_uuid } }
        if list.any?
          puts_row ['instance','state','cloud','address']
          map.instances.each do |i|
            c = Cloud.clouds.find { |c| c.options.uuid==i.cloud_uuid }
            cloud_name = c ? "#{' '*c.depth}#{c.options.name}" : '-'
            puts_row [i.id,i.state,cloud_name,i.address]
          end
        else
          puts 'No instances running.'
        end
      end

      def show_volumes
        if map.volumes.any? 
          puts_row ['volume','status','attachment','instance','device'] 
          map.volumes.each { |i| puts_row [i.id,i.status,i.attachment,i.instance_id,i.device] }
        else
          puts 'No volumes.'
        end
      end

      def puts_row items
        puts items.map { |i| i.to_s.ljust(20) }.join("\t")
      end

      def prune
        pruning = []
        pruning = super
        if pruning.any?
          puts "Pruning #{pruning.size} instance(s)."
          remoter.terminate pruning
          map.remove_instances -= pruning        
        else
          #      puts "No pruning needed."
        end
      end
      
      
    end
  end
end