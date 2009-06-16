module Healing
  module Structure
    class Recipe <  Resource

      class Lingo < Base::Lingo
      end
      
      def initialize parent, file, options={}, &block
        super parent, options.merge(:file=>file), &block
        pa = parent_cloud
        lingo = eval("#{pa.class.name}::Lingo").new(self)
        lingo.options = Options.new(options)
        lingo.instance_eval ::File.read("recipes/#{file}.rb")
      end
      
      def describe_name
        puts_title :recipe, file
      end
      
      def describe_settings
     #   @options.each_pair { |k,v| puts_setting k,v }
      end


    end
  end
end