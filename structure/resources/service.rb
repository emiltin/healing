module Healing
  module Structure

    class Service < Resource
      
      class Stopped < Resource
        class Lingo < Structure::Cloud::Lingo
        end
        def describe_name
          puts_title :while_stopped, ''
        end
        def heal
          describe_name
          super
        end
        def heal_resources
          @parent.stop
          super
          #the service will set it's state itself
        end
        
      end
      
      class Lingo < Resource::Lingo
        def on
          @parent.state = :on
        end
        
        def off
          @parent.state = :off
        end
        
        def while_stopped &block
          Service::Stopped.new( @parent, {:root => @parent.root}, &block)
        end
      end
  
      def initialize parent, name, options={}, &block
        if name.is_a? Hash
          super parent, options.merge(:name=>name.to_a.flatten[0], :state => name.to_a.flatten[1]), &block
        else
          super parent, options.merge(:name=>name), &block
        end
      end
      
      def defaults
        {:state => :on}
      end
      
      def heal
        describe_name
        stop if stop_during_setup?
        heal_resources
        case state
          when :on
            start
    #      when :restart
    #        restart
          when :off
            stop
        end
      end
      
      def start
        #TODO method of starting services depend on platform..
        run "sudo /etc/init.d/#{name} start"
      end
      
      def stop
        run "sudo /etc/init.d/#{name} stop"
      end
      
      def restart
        run "sudo /etc/init.d/#{name} restart"
      end
      
      def describe_name
        puts_title :service, "#{name} (#{state})"
      end

      def describe_settings
      end

    end
  end
end

