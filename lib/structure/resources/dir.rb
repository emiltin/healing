module Healing
  module Structure
    class Dir < Resource

      def initialize parent, path, options={}
        super parent, options.merge(:path => path)
      end

      def defaults
        { :mode => '0777' }
      end

      def heal
        describe_name
        if options.source
          run "cp -R #{options.source} #{options.path}"
        else
          run "mkdir -p #{options.path}"
        end  
        run "chmod '#{options.mode}' #{options.path}" if options.mode
      end

      def describe_name
        puts_title :dir, options.path
      end
      
      def describe_settings
        puts_setting :mode if options.mode
      end


    end
  end
end