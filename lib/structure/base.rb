require 'digest/sha1'

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

      attr_accessor :resources, :parent, :root, :depth, :options, :index

      def initialize parent, options={}, &block
        @resources = []
        @parent = parent
        @root = parent.root if parent
        @index = @root.new_index
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
        path = [nearest_cloud]
        path.unshift path.first.parent_cloud while path.first.parent_cloud
        path
      end

      def defaults
        {}
      end

      def validate
      end
      
      def healed?
        false
      end
      
      def subs_healed?
        @resources.all? { |r| r.healed? }
      end
      

      def extract str, len=100
        max = (len-5)*0.5
        if str.size<=len
          s = str
        else
          s = str.strip
          first = s.split("\n").first.strip
          last = s.split("\n").last.strip
          s = "#{first[0..max]} ... #{last[-max..-1]}"
        end
        s.strip.gsub(/\n/,';')
      end
      
      def heal_and_report
        row = root.reporter.add_row self, :fingerprint => "#{hexdigest}", :item=> "#{indent}#{ref}"
        begin
          result = heal
          case result
          when String
            row.columns[:status] = :ok
            row.columns[:message] = extract(result)
          when Hash
            pair = result.first
            row.columns[:status] = result.keys.first
            row.columns[:message] = extract(result.values.first)
          else
            row.columns[:status] = result==false ? :fail : :ok
          end
        rescue Exception => e
          row.columns[:status] = :fail
          row.columns[:message] = extract(e.to_s)
        end
      end

      def heal
        heal_resources
        true
      end
      
      def cloud_path_string
        cloud_path.map { |c| c.options.name }.join('/')
      end
      
      def heal_resources
        @resources.each { |c| c.heal_and_report }
      end
      
      def hexdigest
        s = ref_path
        s += options.to_hash.map { |k,v| "#{k}:#{v}" }.join(',')
        Digest::SHA1.hexdigest(s)
      end
      
      def ref_path
        @parent ? "#{@parent.ref_path},#{ref}" : ref
      end
      
      def ref
        options.comment? ? "#{name} #{type} (#{options.comment})" : "#{name} #{type}"
      end
      
      def format_name
        self.class.name.gsub(/.*::/,'')
      end
      
      def format_title
      end
      
      def diagnose_and_report
        row = root.reporter.add_row self, :fingerprint => "#{hexdigest}", 
        :item=> "#{indent}#{name}", :type => type
        begin
          result = diagnose
          case result
          when String
            row.columns[:status] = :fail
            row.columns[:message] = extract(result)
          when Hash
            pair = result.first
            row.columns[:status] = result.keys.first
            row.columns[:message] = extract(result.values.first)
          else
            row.columns[:status] = result ? :ok : :fail
          end
        rescue Exception => e
          row.columns[:status] = :fail
          row.columns[:message] = extract(e.to_s)
        end
        diagnose_resources
      end
      
      def diagnose
        healed?
      end
      
      def diagnose_resources
        @resources.each { |c| c.diagnose_and_report }
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
     #   log "#{k}: #{v}", 1
      end

      def order
        puts "  #{self.class.name.gsub(/.*::/,'')}: #{name}"
      end
      
      def indent
        '. '*@depth
      end
      
      def name
        options.name
      end
      
      def type
        self.class.name.gsub(/.*::/,'').downcase
      end
 
      def describe options={}
        root.describer.add_row self, :fingerprint => "#{hexdigest}", :item=> "#{indent}#{ref}"
#        puts "#{indent}#{ref}"
        #describe_name
        #describe_settings
        describe_children options if options[:recurse]
      end
      
      def describe_name
        format_name
      end
      
      def describe_settings
      end

      def describe_children options={}
        @resources.each { |item| item.describe options }
      end


    end
  end
end
