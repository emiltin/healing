
module Healing
  module Provider

    class Base
      attr_reader :name
    
      def self.build name
        case name.to_s.downcase
        when "ec2"
          Healing::Provider::EC2.new :name => name
        else
          raise "Unknown provider '#{name}'."
        end
      end
    
      def initialize options
        @name = options[:name]
      end
  
      def launch options
      end
  
      def terminate instances
      end
  
      def instances options
      end
  
    end

  end
  
end