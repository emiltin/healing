module Healing
  module Structure
    class Volume <  Base
  
      attr_accessor :id, :device
      
      def initialize parent, id, options={}
        super parent, options
        @parent.volumes << self
        @id = id
        @device = options[:device]
        has do
          package 'xfsprogs'
          execute 'add device', 'mkfs.xfs /dev/sdh'
          execute 'add volume to filetab', 'echo "/dev/sdh /vol xfs noatime 0 0" >> /etc/fstab'
          execute 'mount EBS volume', 'mkdir /vol && mount /vol'
        end
      end
   
      def heal
        super
      end
    
      def revert
      end
 
      def describe options={}
        log "volume: #{@id}"
        log "device: #{@device}", 1
        super options
      end
    
    end
  end
end



