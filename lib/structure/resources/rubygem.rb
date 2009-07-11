require 'yaml'

module Healing
  module Structure
    class Rubygem < Resource
      
      @@dependencies = {}
      @@gems = {}
      
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
      
      def self.scan_gems
        @@gems = {}
        parse_gem_list Healing::App::Base.run_locally("gem list --local", :quiet => true)
      end
      
      def self.parse_gem_list list
        list.split("\n").map do |line|
          name = line.match( /\w*/ ).to_s
          md = line.match /\((.*)\)/
          versions = md[1].scan /[\d\.]+/
          @@gems[ name ] = versions
        end
      end

      def self.scan_gem name
        parse_gem_list Healing::App::Base.run_locally("gem list #{name} --local", :quiet => true)
      end
      
      def self.report_gems
        @@gems.each_pair do |k,v|
          puts "#{k}: #{v.inspect}"
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
        if @@gems[options.name.to_s]
          puts_title :gem, "#{options.name} (already installed)"
        else
          describe_name
          heal_resources    #heal any dependecies first
          version = "-v #{options.version}" if options.version
          run "gem install --no-rdoc --no-ri #{version} #{options.name}"
          Rubygem.scan_gem options.name.to_s
        end
      end

      def revert
        log "removing gem #{options.name}"
        run "gem uninstall #{options.name}"
      end

      def format_title
        options.name
      end
      
      def describe_name
        puts_title :gem, options.name
      end

    end
  end
end
