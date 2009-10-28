module Healing
  module Structure
    class Root < Cloud

      include Healing::Threading

      attr_accessor :remoter, :map, :armed, :clouds, :reporter, :remote_reporter, :describer
      
      def initialize o, &block
        raise "You can only define one root cloud!" if Cloud.root
        Cloud.root = self
        @clouds = []
        @root = self
        @index_count = 0
        super  nil, o, &block
        @map = Remoter::Map.new self
        build_remoter
        
        @reporter = ReportTable.new( Table::Column.new(:status),
                                  Table::Column.new(:item),
                                  Table::Column.new(:message),
                                  Table::Column.new(:fingerprint))

        @remote_reporter = SummeryTable.new( Table::Column.new(:ok),
                                         Table::Column.new(:fail),
                                         Table::Column.new(:item),
                                         Table::Column.new(:message))

        @describer = ReportTable.new( Table::Column.new(:item))
                                                                
      end  
      
      def new_index
        i = @index_count
        @index_count += 1
        i
      end
      
      def report
        puts @reporter.to_s
      end

      def report_remote
        @map.instances.each { |i| @remote_reporter.parse i.output }
        puts @remote_reporter.to_s
      end

      def describe options={}
        super options
        puts @describer.to_s
      end
      
      def build_remoter
        @remoter = Healing::Remoter::Base.build options.remoter
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
          begin
            Healing::App::Base.run_locally "rsync -e 'ssh -i #{options.key} -o StrictHostKeyChecking=no' -ar #{BASE} root@#{instance.address}:/healing", :quiet => true
          rescue Exception => e
            puts "ERROR: "+ e.to_s
          end
            #TODO how to handle ssh/rsync error messages?
        end
      end
            
      def show_instances
        list = map.instances.map { |i| [i,Cloud.clouds.find { |c| c.options.uuid==i.cloud_uuid }] }
        list.reject! {|p| p[1]==nil }
        if list.any?
          puts_row ['instance','state','cloud','address']
          list.sort! { |a,b| a[1].depth<=>b[1].depth }
          list.each do |pair|
            i = pair[0]
            c = pair[1]
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
        pruning = super
        
        orphaned = root.map.instances
        @clouds.each { |c| orphaned -= c.my_instances }
        pruning += orphaned
        pruning.uniq!
        
        if pruning.any?
          puts "Pruning #{pruning.size} instance(s)."
          remoter.terminate pruning
          map.remove_instances pruning        
        else
          puts "No pruning needed."
        end
      end
      
      def heal_remote
        App::Provisioner.new(self).heal
        install
        map.instances.each_in_thread "Healing #{map.instances.size} instance(s)" do |i|
          i.execute("cd /healing && bin/heal-local")
        end
      end


      def diagnose_remote
        App::Provisioner.new(self).diagnose
        install
        map.instances.each_in_thread "Diagnosing #{map.instances.size} instance(s)" do |i|
          i.execute("cd /healing && bin/heal-diagnose-local")
        end
      end

      
    end
  end
end


def cloud name, options={}, &block
  Healing::Structure::Root.new( options.merge(:name=>name), &block )
end

