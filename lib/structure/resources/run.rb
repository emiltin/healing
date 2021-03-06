module Healing
  module Structure
    class Run <  Resource

      def initialize parent, name, o={}, &block
        super(parent, o.merge(:name=>name)) {}
        @block = block
      end
      
      def ref
        "#{options.name}"
      end
      
      def format_title
        options.name
      end
      
      def describe_name
        puts_title :run, options.name
      end
      
      def describe_settings
        puts_setting :description if options.description?
      end
      
      def heal
        describe_name
        instance_eval &@block
      end
  
    end
  end
end