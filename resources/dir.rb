class Heal
  
  class Dir <  Resource
  
    def initialize path, options={}
      super options
      @path = path
    end
  
    def defaults
      { :mode => '0777' }
    end
  
    def heal
      log "dir #{@path}"
      if @options[:source]
        run "cp -R #{@options[:source]} #{@path}"
      else
        run "mkdir #{@path}"
      end  
      run "chmod '#{@options[:mode]}' #{@path}" if @options[:mode]
    end
    
    def revert
      log "reverting dir '#{@path}'"
#      run "rm -rf #{@path}"
    end
    
  end
end

def dir path, options={}
  r = Heal::Dir.new path, options
end
