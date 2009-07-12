module Healing
  module Structure
    class Recipe <  Resource

      def initialize parent, opt={}, &block
        super parent, opt, &block
        lingo(self,opt).read_file options.file if options.file
      end
      
      def ref
        "#{options.name} recipe"
      end

      def describe_name
        puts_title :recipe, options.name
      end
      
      def heal
        describe_name
        super
      end
      
      def format_title
        options.name
      end
      
    end
  end
end