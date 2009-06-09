module Healing
  module Structure
    class Package < Resource
  
      def initialize parent, name, options={}
        super parent, options.merge(:name => name)
     #   parent_cloud.packages << self
      end

      def heal
        describe_name
        run "apt-get install -y #{name} "
      end

      def revert
        log "removing package #{name}"
        run "apt-get remove -y #{name}"
      end

      def describe_name
        puts_title :package, name
      end

    end
  end
end
