module Healing
  module Structure
    class Execute < Resource
 
      def initialize parent, name, command, options={}
        super parent, options.merge(:name=>name, :command => command)
      end

      def heal
        describe_name
        run options.command
  #      self.instance_eval &@block if @block
      end
      
      def format_title
        "#{options.name}: #{options.command}"
      end
      
      def describe_name
        puts_title :execute, format_title
      end
      
      def describe_settings
        puts_setting :command
#        puts_setting :block if block.to_s
      end


    end
  end
end
