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

      def initialize parent, name, options={}
        super parent, options.merge(:name => name)
        include_dependencies
      end
      
      def compile
        parent_cloud.gems << self
      end
      
      def include_dependencies
        packs = @@dependencies[name]
        lingo do
          packs.each { |pack| package pack } if packs
        end
      end
      
      def heal
        heal_resources
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
