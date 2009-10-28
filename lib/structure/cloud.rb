module Healing
  module Structure
    class Cloud < Base

      class Lingo < Base::Lingo
        def cloud name, options={}, &block
          Cloud.new( @target, options.merge(:name=>name), &block)
        end

        def instance name, options={},&block
          Instance.new( @target, options.merge(:name=>name, :num_instances => 1), &block)
        end

        def remoter p
     #     raise "You can only specify one remoter!" if @target.options.remoter
          @target.options.remoter = p
        end

        def image i
          @target.options.image = i
        end

        def availability_zone z
          @target.options.availability_zone = z
        end

        def key path
          @target.options.key = path
        end

        def uuid u
          @target.options.uuid = u.to_s
        end

        def instances number
          @target.options.num_instances = number
        end

        def recipe file, options={}, &block
          if block
            Recipe.new @target, options.merge(:name=>file), &block
          else
            Recipe.new @target, options.merge(:name=>file,:file=>file)
          end
        end

        #git_repo() will instantiate a Healing::Structure::GitRepo object, etc..
        def method_missing(sym, *args, &block)
     #     if match = sym.to_s.match(/^not_(.+)/)
    #        sym = match[1]
          eval("Healing::Structure::#{sym.to_s.camelcase}").new @target, *args, &block
        end
      end
      

      attr_accessor :subclouds, :volumes, :clouds, :packages, :gems, :collection

      class << self
        attr_accessor :root
      end

      @@clouds = []
      def self.clouds
        @@clouds
      end

      def initialize parent, options, &block
        @subclouds = []
        @volumes = []
        super parent, options
        raise "Clouds must be created with a block!" unless block
        @parent.subclouds << self if @parent
        root.clouds << self
        Cloud.clouds << self 
      end
      
      def defaults
        { :image => 'ami-bf5eb9d6', :remoter => :ec2, :num_instances => 0 }
      end

      def compile
        @gems = parent_cloud ? parent_cloud.gems.dup : []
        @packages = parent_cloud ? parent_cloud.packages.dup : []
        @collection = parent_cloud ? parent_cloud.collection.dup : []
        @resources.each { |i| i.compile }
        @subclouds.each { |i| i.compile }
      end
      
      def preflight
        puts "Cloud: #{name}"
        puts "  Packages: "+@packages.map { |p| p.name }.join(', ').to_s if @packages.any?
        puts "  Gems: "+@gems.map { |p| p.name }.join(', ').to_s if @gems.any?
        puts "  Resources: "+@resources.map { |p| p.name }.join(', ').to_s if @resources.any?
        @subclouds.each { |i| i.preflight }
      end
      
      def nearest_cloud
        self
      end

      def my_instances
        root.map.instances.select { |i| i.cloud_uuid==options.uuid }
      end

      def find_cloud cloud_uuid
        return self if cloud_uuid==options.uuid
        @subclouds.each do |c| 
          r = c.find_cloud cloud_uuid
          return r if r
        end
        nil
      end

      def prune
        pruning = []
        cur = my_instances
        n = cur.size - options.num_instances
        n.times { pruning << cur.shift } if n>0   #pick instances to terminate
        @subclouds.each { |c| pruning.concat [c.prune].flatten.compact }
        pruning
      end

      def validate
        raise "Cloud uuid not set in '#{options.name}'" unless options.uuid || options.num_instances==0
      end

      def root?
        false
      end

      def remoter
        root.remoter
      end

      def image
        root.options.image
      end
      
      def reporter
        root.reporter
      end
      
      def self.find_cloud_with_uuid uuid
        @@clouds.find { |c| c.options.uuid==uuid }
      end

      def key_name
        ::File.basename options.key, ".*"
      end

      def get_uuid
        uuid
      end

      def describe_children options={}
        super
        @subclouds.each { |item| item.describe options }
      end

      def describe_name
        puts_title :cloud, options.name
      end
      
      def describe_settings
        puts_setting :uuid, options.uuid if options.uuid
        puts_setting :instances, options.num_instances if options.num_instances
      end
    
      def heal_from_root
        cloud_path.each do |c|
          c.heal_and_report
        end
      end

      def diagnose_from_root
        cloud_path.each do |c|
          c.diagnose_and_report
        end
      end
      
      def healed?
        true
      end

      def order
        if @collection.any?
          puts "Cloud: #{name}"
          @collection.each do |i|
            i.order
          end
        end
      end
      
      
      def reorder
        copy = @collection.dup
        copy.each do |i|
          if i.is_a? Rubygem
            @collection.delete i
            @collection.unshift i
          end
        end
        copy.each do |i|
          if i.is_a? Package
            @collection.delete i
            @collection.unshift i
          end
        end
      end
      
      def type
        "cloud"
      end
      
      def ref
        "#{options.name} cloud"
      end
      
      def format_name
        'Cloud'
      end
      
      def format_title
        options.name
      end
      
    end
  end
end
