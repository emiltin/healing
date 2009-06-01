module Healing
  module Structure
    class Gem < Base
  
      def initialize name, cloud, options={}
        super cloud, options
        @gem = name
      end

      def heal
        describe_name
        run "gem install --no-rdoc --no-ri #{@gem} "
      end

      def revert
        log "removing gem #{@gem}"
        run "gem uninstall #{@gem}"
      end

      def describe_name
        log "gem: #{@gem}"
      end

    end
  end
end
