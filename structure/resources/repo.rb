module Healing
  module Structure
    class Repo <  Base

      def initialize parent, path, options={}
        super parent, options.merge(:path => path)
      end

      def heal
        super
        describe_name
      end
      
      def describe_name
        puts_title :repository, path
      end
      
      def describe_settings
        puts_setting :url if url
      end


    end
  end
end