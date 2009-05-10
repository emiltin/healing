class Healing
  
  class Dir <  Resource
  
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
        run "cp -R #{@options[:source]} #{@path}"
      else
        run "mkdir -p #{@path}"
      end  
      run "chmod '#{@options[:mode]}' #{@path}" if @options[:mode]
    end
    
    def revert
      @cloud.log "reverting dir '#{@path}'"
#      run "rm -rf #{@path}"
    end

    def describe options={}
      log "dir: #{@path}"
    end
    
  end
end
