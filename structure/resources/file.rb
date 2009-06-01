module Healing
  module Structure
    class File <  Base
  
      def initialize parent, path, options={}
        super parent, options
        @path = path
      end
  
      def defaults
        { :mode => '0777' }
      end
  
      def heal
        describe_name
        if @options[:source]
          run "cp #{@options[:source]} #{@path}"
        else
          run "echo '#{@options[:content]}' > #{@path}"
        end  
        run "chmod '#{@options[:mode]}' #{@path}" if @options[:mode]
      end
    
      def revert
        log "reverting file '#{@path}'"
        run "rm #{@path}"
      end
 
      def describe_name
        log "file: #{@path}"
      end
    
      def describe_settings
        if @options[:content]
          s = @options[:content].strip.split("\n")[0]
          max = 50
          str =  s.size > max ? "#{s[0..max]}..." : s
          log_setting "content: '#{str}'" if str
        end
      end
    
    end
  end
end

