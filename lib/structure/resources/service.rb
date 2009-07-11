module Healing
  module Structure

    class Service < Resource
      
      class WhileStopped < Resource
        class Lingo < Structure::Resource::Lingo
        end
        
        def describe_name
          puts_title :while_stopped, ''
        end
        
        def heal_resources
          unless subs_healed?
            describe_name
            @parent.stop
            #the service will set it's state itself
          else
            "Stop not needed."
          end
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
          Service::WhileStopped.new( @owner, {}, &block)
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
#        stop if options.stop_during_setup?
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
        run "/etc/init.d/#{options.name} start"
        #unfortunately, the output is varies with the services, so no easy way to parse it
#        status = run "/etc/init.d/#{options.name} status", :quiet => true
#       if status.match /is stopped/      #only works with mysql, not with apache.. etc...
      end
      
      def stop
        run "/etc/init.d/#{options.name} stop"
      end
      
      def restart
        run "/etc/init.d/#{options.name} restart"
      end
      
      def format_title
        "#{options.name}: #{options.state}"
      end
            def describe_name
        puts_title :service, format_title
      end

      def describe_settings
      end

    end
  end
end

