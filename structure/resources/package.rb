module Healing
  module Structure
    class Package < Base
  
      def initialize package, cloud, options={}
        super cloud, options
        @package = package
      end

      def heal
        describe
        run "apt-get install -y #{@package} "
      end

      def revert
        log "removing package #{@package}"
        run "apt-get remove -y #{@package}"
      end

      def describe options={}
        log "package: #{@package}"
      end

    end
  end
end
