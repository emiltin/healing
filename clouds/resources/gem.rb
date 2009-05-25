module Healing
  
  class Gem < Element
  
    def initialize name, cloud, options={}
      super cloud, options
      @gem = name
    end

    def heal
      describe
      run "gem install --no-rdoc --no-ri #{@gem} "
    end

    def revert
      log "removing gem #{@gem}"
      run "gem uninstall #{@gem}"
    end

    def describe options={}
      log "gem: #{@gem}"
    end

  end

end
