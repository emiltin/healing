module Healing
  module Structure
    class Service < Base

      class Lingo < Base::Lingo
        def on
          @parent.state = :on
        end
        
        def off
          @parent.state = :off
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
        case state
          when :on
            start
          when :restart
            restart
          when :off
            stop
        end
      end
      
      def start
        #TODO method of starting services depend on platform..
        run "/etc/init.d/#{name} start"
      end
      
      def stop
        run "/etc/init.d/#{name} stop"
      end
      
      def restart
        run "/etc/init.d/#{name} restart"
      end
      
      def describe_name
        puts_title :service, "#{name}: #{state}"
      end

      def describe_settings
        puts_setting :boom if boom
        puts_setting :state
      end

    end
  end
end

