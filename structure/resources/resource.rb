module Healing
  module Structure
    class Resource <  Base

      def initialize parent, options={}
        super parent, options
        @parent.resources << self
      end

    end
  end
end