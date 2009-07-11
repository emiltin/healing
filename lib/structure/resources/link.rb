module Healing
  module Structure
    class Link <  Resource
  
      def initialize parent, path, target, o={}
        super parent, o.merge(:path => path, :target => target)
      end
  
      def healed?
        return ::File.exist?(options.path) && ::File.symlink?(options.path)
      end
      
      def heal
        describe_name
        FileUtils.ln_s options.target, options.path
#        run "ln -s #{options.path} #{options.target}"
      end
      
      def format_title
        "#{options.path} --> #{options.target}"
      end
      
    
      def describe_name
        puts_title :link, format_title
      end
      
      def describe_settings
        puts_setting :path
        puts_setting :target
      end
    
    end
  end
end

