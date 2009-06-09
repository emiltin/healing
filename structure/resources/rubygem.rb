module Healing
  module Structure
    class Rubygem < Base

      def initialize parent, name, options={}
        super parent, options.merge(:name => name)
   #     parent_cloud.gems << self
      end

      def heal
        describe_name
        run "gem install --no-rdoc --no-ri #{name} "
      end

      def revert
        log "removing gem #{name}"
        run "gem uninstall #{name}"
      end

      def describe_name
        puts_title :gem, name
      end

    end
  end
end
