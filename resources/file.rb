class Heal
 
  class File <  Resource
  
    def initialize path, options={}
      super options
      @path = path
    end
  
    def defaults
      { :mode => '0777' }
    end
  
    def heal
      log "file #{@path}"
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
    
  end

end

def file path, options={}
  r = Heal::File.new path, options
end
