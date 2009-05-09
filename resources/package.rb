class Heal
  
  class Package <  Resource
  
    def initialize package, options={}
      super options
      @package = package
    end

    def heal
      log "package #{@package}"
      run "apt-get install #{@package}"
    end

    def revert
      log "removing package '#{@package}'"
      run "apt-get remove #{@package}"
    end
  end

end

def package package, options={}
  r = Heal::Package.new package, options
end