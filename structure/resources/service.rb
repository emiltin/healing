module Healing
  module Structure
    class Service < Base
  
      def initialize parent, name, options={}
        super parent, options.merge(:name=>name)
      end

      def heal
        describe_name
        start
      end
      
      def start
        #TODO method of starting services depend on platform..
        run "/etc/init.d/#{name} start"
      end
      
      def stop
        run "/etc/init.d/#{name} stop"
      end
      
      def restart
      end
      
      def describe_name
        puts_title :service, name
      end

    end
  end
end
