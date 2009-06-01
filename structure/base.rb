module Healing
  module Structure
    class Base
      
      attr_accessor :children, :parent, :depth
      
      def initialize parent, options={}     
        @children = []
        @parent = parent
        @parent.children << self if parent
        @options = defaults.merge(options)
        @depth = @parent ? @parent.depth+1 : 0
      end

      def defaults
        {}
      end

      def heal
        @children.each { |c| c.heal }
      end

      def revert
      end

      def run cmd
        Healing::App::Base.run_locally cmd
      end

      def log str, level=0
        puts '   '*(@depth+level) + str
      end
      
      def log_name str
        log msg
      end

      def log_setting str
        log str, 1
      end
      
      def has &block
        Cloud::Lingo.new(self).instance_eval &block
      end
      
      def describe options={}
        describe_name
        describe_settings
        describe_children options if options[:recurse]
      end

      def describe_name
      end

      def describe_settings
      end

      def describe_children options={}
        @children.each { |item| item.describe options }
      end
      
    end
  end
end
