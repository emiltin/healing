module Healing
  
  class Dir <  Element
  
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
        Healing::Healer.run_locally "cp -R #{@options[:source]} #{@path}"
      else
        Healing::Healer.run_locally "mkdir -p #{@path}"
      end  
      Healing::Healer.run_locally "chmod '#{@options[:mode]}' #{@path}" if @options[:mode]
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