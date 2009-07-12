module Healing
  module Structure
    class Package < Resource
  
      def initialize parent, name, options={}
        super parent, options.merge(:name => name)
      end
      
      def compile
        parent_cloud.packages << self
      end
      
      def heal
        describe_name
        run "apt-get install -y #{options.name} "
        true
      end

      def revert
        log "removing package #{options.name}"
        run "apt-get remove -y #{options.name}"
      end

      def ref
        "#{options.name} package"
      end
      
      def format_title
        options.name
      end
      
      def describe_name
        puts_title :package, options.name
      end

    end
  end
end
