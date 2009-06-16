module Healing
  module Structure
    class Resource <  Base

      def initialize parent, options={}
        super parent, options
        @parent.resources << self
      end
      
      def compile
        parent_cloud.collection << self if parent_cloud
      end
      
    end
  end
end