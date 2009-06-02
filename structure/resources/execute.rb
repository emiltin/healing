module Healing
  module Structure
    class Execute < Base
  
      def initialize name, command, cloud, options={}, &block
        super cloud, options
        @name = name
        @command = command
        @block = block
      end

      def heal
        describe_name
        run @command if @command
        self.instance_eval &@block if @block
      end
    
      def describe_name
        log "execute: #{@name}"
      end

    end
  end
end
