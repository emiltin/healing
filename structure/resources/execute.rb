module Healing
  module Structure
    class Execute < Base
  
      def initialize name, command, cloud, options={}
        super cloud, options
        @name = name
        @command = command
      end

      def heal
        describe
        run @command
      end
    
      def describe options={}
        log "execute: #{@name}"
      end

    end
  end
end
