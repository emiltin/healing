module Healing
  module Structure
    class Execute < Resource
 
      def initialize parent, name, command, options={}
        super parent, options.merge(:name=>name, :command => command)
      end

      def heal
        describe_name
        run options.command
        true
      end
      
      def ref
        "#{options.name}"
      end

      def format_title
        "#{options.name}: #{options.command}"
      end
      
      def describe_name
        puts_title :execute, format_title
      end
      
      def describe_settings
        puts_setting :command
      end


    end
  end
end
