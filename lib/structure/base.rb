module Healing
  module Structure
    class Base

      class Lingo
        
        attr_accessor :options, :target, :owner
        
        def initialize owner,target, options={}
          @owner = owner
          @target = target
          @options = Options.new(options)
        end
        
        def method_missing sym, *args, &block
          supervisor = @owner.parent
          if supervisor
            lingo = supervisor.lingo(@target)
            lingo.send sym, *args, &block
          else
            raise "Unknown lingo method '#{sym}'"
          end
        end
        
        def read_file file
          instance_eval ::File.read(BASE+"/lib/recipes/#{file}.rb")
        end
        
      end

      attr_accessor :resources, :parent, :root, :depth, :options

      def initialize parent, options={}, &block
        @resources = []
        @parent = parent
        @root = parent.root if parent
        @options = Options.new defaults.merge(options)
        @depth = @parent ? @parent.depth+1 : 0
        eval_block &block
        validate
      end
      
      def lingo target=self, options={}, &block
        l = eval("#{self.class.name}::Lingo").new(self,target, options)
        l.instance_eval &block if block
        l
      end
      
      def recipe name='', options={}, &block
        lingo.recipe name, options, &block
      end
      
      def run_recipe name='', options={}, &block
        recipe(name, options, &block).heal
      end
      
      def compile
      end
      
      def eval_block &block
        lingo.instance_eval &block if block
      end
      
      def parent_cloud
        @parent ? @parent.nearest_cloud : nil
      end
      
      def nearest_cloud
        @parent.nearest_cloud
      end
      
      def cloud_path
        path = [self]
        path.unshift path.first.parent while path.first.parent
        path
      end

      def defaults
        {}
      end

      def validate
      end

      def heal
        heal_resources
      end
      
      def heal_resources
        @resources.each { |c| c.heal }
      end
      
      def revert
      end

      def run cmd, options={}
        Healing::App::Base.run_locally cmd, options
      end

      def log str, level=0
        puts '. '*(@depth+level) + str
      end

      def puts_title k,v
        log "#{k.to_s.capitalize.gsub('_',' ')}: #{v}"
      end

      def puts_setting k,v=nil
        v = options.send k unless v
        if v
          max = 50
          v = v.to_s.strip.split("\n")[0]
          v = "#{v[0..max]}..." if v && v.size > max
        end
        log "#{k}: #{v}", 1
      end

      def order
        puts "  #{self.class.name.gsub(/.*::/,'')}: #{name}"
      end
      
      def describe options={}
        describe_name
        describe_settings
        describe_children options if options[:recurse]
      end

      def describe_settings
      end

      def describe_children options={}
        @resources.each { |item| item.describe options }
      end


    end
  end
end
