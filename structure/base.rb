module Healing
  module Structure
    class Base

      class Lingo
        
        attr_accessor :options
        
        def initialize parent
          @parent = parent
          @options = {}
        end
      end

      attr_accessor :resources, :parent, :depth

      def initialize parent, options={}, &block
        @resources = []
        @parent = parent
        @options = defaults.merge(options)
        @depth = @parent ? @parent.depth+1 : 0
        eval_block &block
        validate
      end
      
      def compile
      end
      
      def eval_block &block
        eval("#{self.class.name}::Lingo").new(self).instance_eval &block if block
      end
      
      def parent_cloud
        @parent ? @parent.nearest_cloud : nil
      end
      
      def nearest_cloud
        @parent.nearest_cloud
      end
      
      def recipe options={}, &block
        pa = parent_cloud
        lingo = eval("#{pa.class.name}::Lingo").new(self)
        lingo.options = Options.new(options)
        lingo.instance_eval &block
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

      def run cmd
        Healing::App::Base.run_locally cmd
      end

      def log str, level=0
        puts '.  '*(@depth+level) + str
      end

      def puts_title k,v
        log "#{k.to_s.capitalize.gsub('_',' ')}: #{v}"
      end

      def puts_setting k,v=nil
        v = @options[k] unless v
        if v
          max = 50
          v = v.to_s.strip.split("\n")[0]
          v = "#{v[0..max]}..." if v && v.size > max
        end
        log " #{k}: #{v}", 1
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

      def method_missing(sym, *args, &block)
        if match = sym.to_s.match(/(.+)\?/)
          @options[match[1].to_sym]!=nil &&
          (@options[match[1].to_sym]!=false && @options[match[1].to_sym]!= :false && @options[match[1].to_sym]!=0 )
        elsif match = sym.to_s.match(/(.+)=/)
          @options[match[1].to_sym] = args[0]
          args[0]
        else
          @options[sym]
        end
      end


    end
  end
end
