module Healing
 
  class File <  Resource
  
    def initialize path, cloud, options={}
      super cloud, options
      @path = path
    end
  
    def defaults
      { :mode => '0777' }
    end
  
    def heal
      describe
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
 
    def describe options={}
      c = content_summary
      c = " = '#{c}'" if c
      log "file: #{@path}#{c}"
    end
    
    def content_summary
      if @options[:content]
        s = @options[:content].strip.split("\n")[0]
        max = 50
        return s.size > max ? "#{s[0..max]}..." : s
      end
    end
    
  end

end

