module Healing
  module Structure
    class File <  Resource
  
      def initialize parent, path, options={}
        super parent, options.merge(:path => path)
      end
  
      def defaults
        { :mode => '0777' }
      end
  
      def heal
        describe_name
       if options.remove?
          run "rm #{options.path}"
        else
          if options.source?
            run "cp #{options.source} #{options.path}"
          else
            run "echo '#{options.content}' > #{options.path}"
          end  
          run "chmod '#{options.mode}' #{options.path}" if options.mode?
        end
      end
    
 
      def describe_name
        puts_title :file, options.path
      end
      
      def describe_settings
        if options.remove?
          puts_setting :remove
        else
          puts_setting :content if options.content
          puts_setting :mode if options.mode
        end
      end
    
    end
  end
end

