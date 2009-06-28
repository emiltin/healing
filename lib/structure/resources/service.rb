module Healing
  module Structure

    class Service < Resource
      
      class Stopped < Resource
        class Lingo < Structure::Resource::Lingo
        end
        def describe_name
          puts_title :while_stopped, ''
        end
        def heal
          describe_name
          super
        end
        def heal_resources
          @owner.stop
          super
          #the service will set it's state itself
        end
        
      end
      
      class Lingo < Resource::Lingo
        def on
          @owner.options.state = :on
        end
        
        def off
          @owner.options.state = :off
        end
        
        def while_stopped &block
          Service::Stopped.new( @owner, {}, &block)
        end
      end
  
      def initialize parent, name, o={}, &block
        if name.is_a? Hash
          super parent, o.merge(:name=>name.to_a.flatten[0], :state => name.to_a.flatten[1]), &block
        else
          super parent, o.merge(:name=>name), &block
        end
      end
      
      def defaults
        {:state => :on}
      end
      
      def heal
        describe_name
        stop if stop_during_setup?
        heal_resources
        case options.state
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
        run "sudo /etc/init.d/#{options.name} start"
      end
      
      def stop
        run "sudo /etc/init.d/#{options.name} stop"
      end
      
      def restart
        run "sudo /etc/init.d/#{options.name} restart"
      end
      
      def describe_name
        puts_title :service, "#{options.name} (#{options.state})"
      end

      def describe_settings
      end

    end
  end
end

