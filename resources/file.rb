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
        Healing::Healer.run_locally "cp #{@options[:source]} #{@path}"
      else
        Healing::Healer.run_locally "echo '#{@options[:content]}' > #{@path}"
      end  
      Healing::Healer.run_locally "chmod '#{@options[:mode]}' #{@path}" if @options[:mode]
    end
    
    def revert
      @cloud.log "reverting file '#{@path}'"
      Healing::Healer.run_locally "rm #{@path}"
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

