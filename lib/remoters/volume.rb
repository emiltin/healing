
module Healing
  module Remoter
    class Volume

      attr_accessor :instance_id, :id, :status, :path, :device, :attachment

      def initialize info
        @id = info[:id]
        @instance_id = info[:instance_id]
        @device = info[:device]
        @status = info[:status]
        @attachment = info[:attachment]
      end
    
      def attach instance
        @instance.cloud.remoter.attach_volume self, @instance
      end
    
      def detach
        @instance.cloud.remoter.detach_volume self, @instance
      end
      
    end
  end
end
