module Healing
  module Structure
    class Package < Base
  
      def initialize parent, package, options={}
        super parent, options
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
