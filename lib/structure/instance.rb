module Healing
  module Structure
    class Instance < Cloud

      def describe_name
        puts_title :instance, options.name
      end
      
    end
  end
end

