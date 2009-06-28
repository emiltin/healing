module Healing
  module Structure
    class Recipe <  Resource

      def initialize parent, opt={}, &block
        super parent, opt, &block
        lingo(self,opt).read_file options.file if options.file
      end
      
      def describe_name
        puts_title :recipe, options.name
      end
      
      def describe_settings
     #   @options.each_pair { |k,v| puts_setting k,v }
      end
      
      def heal
        describe_name
        super
      end
  
    end
  end
end