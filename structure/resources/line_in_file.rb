module Healing
  module Structure
    class LineInFile <  Base
  
      def initialize parent, path, options={}
        super parent, options
        @path = path
        @content = options[:content].strip
      end
  
      def heal
        describe_name
        current = (::File.read(@path) rescue nil)
        ::File.open(@path, "a") { |f| f << "\n#{@content}" } unless current =~ /^#{@content}$/
      end
    
      def revert
        log "reverting file '#{@path}'"
      end
 
      def describe_name
        log "line in file: #{@path}"
      end
    
      def describe_settings
          s = @content.strip.split("\n")[0]
          max = 50
          str =  s.size > max ? "#{s[0..max]}..." : s
          log_setting "line: '#{str}'"
      end
    
    end
  end
end

