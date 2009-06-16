module Healing
  module Structure
    class Volume < Resource
      
      def initialize parent, vol_id, options={:device => '/dev/sdh'}
        super parent, options.merge(:vol_id=>vol_id)
        @parent.volumes << self
        lingo do
          package 'xfsprogs'
          execute 'add device', 'mkfs.xfs /dev/sdh'
          execute 'add volume to filetab', 'echo "/dev/sdh /vol xfs noatime 0 0" >> /etc/fstab'
          execute 'mount EBS volume', 'mkdir /vol && mount /vol'
        end
      end
   
      def describe_name
        puts_title :volume, vol_id
      end
      
      def describe_settings
        puts_setting :device
      end
    
      def describe_children options={}
        super   #or silent
      end

    end
  end
end



