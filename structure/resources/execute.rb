module Healing
  module Structure
    class Execute < Base
  
      def initialize name, command, cloud, options={}
        super cloud, options
        @name = name
        @command = command
      end

      def heal
        describe_name
        run @command
      end
    
      def describe_name
        log "execute: #{@name}"
      end

    end
  end
end
