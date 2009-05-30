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

      def log msg, level=0
        puts '   '*(@depth+level) + msg
      end
      
      def has &block
        Cloud::Lingo.new(self).instance_eval &block
      end
      
      def describe options
        @children.each { |item| item.describe options } if options[:recurse]
      end
      
    end
  end
end
