module Healing
  module Structure
    class Instance < Cloud

      def describe_name
        log "instance: #{@name}"
      end
      
    end
  end
end

