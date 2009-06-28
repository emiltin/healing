require 'yaml'

module Healing
  module Structure
    class Rubygem < Resource
      
      @@dependencies = {}
      def self.load_dependencies path
        h = ::YAML.load_file path
        h.each_pair do |k,v|
          cur = @@dependencies[k]
          if cur
            cur.concat v
            cur.uniq!
          else
            @@dependencies[k] = v
          end
        end
      end

      def initialize parent, name, o={}
        super parent, o.merge(:name => name)
        include_dependencies
      end
      
      def compile
        parent_cloud.gems << self
      end
      
      def include_dependencies
        packs = @@dependencies[options.name]
        if packs
          lingo do
            packs.each { |pack| package pack }
          end
        end
      end
      
      def heal
        describe_name
        heal_resources
        run "gem install --no-rdoc --no-ri #{options.name} "
      end

      def revert
        log "removing gem #{options.name}"
        run "gem uninstall #{options.name}"
      end

      def describe_name
        puts_title :gem, options.name
      end

    end
  end
end
