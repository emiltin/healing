module Healing
  module Structure
    class Repo < Resource

      def initialize parent, path, options={}
        super parent, options.merge(:path => path)
      end

      def heal
        super
        describe_name
      end
      
      def ref
        "#{options.path} repo"
      end

      def describe_name
        puts_title :repository, options.path
      end
      
      def describe_settings
        puts_setting :url if options.url
      end
      
      def format_title
        options.path
      end

    end
  end
end