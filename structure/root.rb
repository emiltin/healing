module Healing
  module Structure
    class Root < Cloud

      include Threading

      attr_accessor :remoter, :image, :map, :armed, :clouds

      def initialize options, &block
        raise "You can only define one root cloud!" if Cloud.root
        Cloud.root = self
        @clouds = []
        super( nil, {:name => options[:name], :root => self}, &block )
        @map = Remoter::Map.new self
      end  

      def remoter
        @remoter
      end

      def image
        @image
      end

      def describe_settings
        super
        puts_setting :key, key_path
        puts_setting :image, @image
        puts_setting :remoter, @remoter.name
      end

      def validate
        super
        raise "You must specify a remoter in the root cloud!" unless @remoter
        raise "You must specify an image in the root cloud!" unless @image
      end

      def root?
        true
      end

      def terminate
        puts "Terminating cloud '#{name}'"
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
          Healing::App::Base.run_locally "rsync -e 'ssh -i #{key_path} -o StrictHostKeyChecking=no' -ar /Users/emiltin/Desktop/healing/ root@#{instance.address}:/healing", :quiet => true
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
        if map.instances.any?
          puts_row ['instance','state','cloud','address']
          map.instances.each do |i|
            c = Cloud.clouds.find { |c| c.uuid==i.cloud_uuid }
            cloud_name = c ? "#{' '*c.depth}#{c.name}" : '-'
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