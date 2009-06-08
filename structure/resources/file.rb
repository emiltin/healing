module Healing
  module Structure
    class File <  Base
  
      def initialize parent, path, options={}
        super parent, options.merge(:path => path)
      end
  
      def defaults
        { :mode => '0777' }
      end
  
      def heal
        describe_name
        if remove?
          run "rm #{path}"
        else
          if @options[:source]
            run "cp #{source} #{path}"
          else
            run "echo '#{content}' > #{path}"
          end  
          run "chmod '#{mode}' #{path}" if @options[:mode]
        end
      end
    
      def revert
        log "reverting file '#{path}'"
        run "rm #{path}"
      end
 
      def describe_name
        puts_title :file, path
      end
      
      def describe_settings
        puts_setting :remove if remove?
        puts_setting :content if content
        puts_setting :mode if mode
      end
    
    end
  end
end

