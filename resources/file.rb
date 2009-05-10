class Healing
 
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
      @cloud.log "reverting file '#{@path}'"
      run "rm #{@path}"
    end
 
    def describe options={}
      log "file: #{@path}"
    end
    
  end

end

