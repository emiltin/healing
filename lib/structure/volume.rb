module Healing
  module Structure
    class Volume < Resource
      
      def initialize parent, vol_id, o={:device => '/dev/sdh'}
        super parent, o.merge(:vol_id=>vol_id)
        nearest_cloud.volumes << self
        lingo self, :device => options.device do
          package 'xfsprogs'
          execute 'add device', "mkfs.xfs #{options.device}"
          execute 'add volume to filetab', "echo \"#{options.device} /vol xfs noatime 0 0\" >> /etc/fstab"
          execute 'mount EBS volume', 'mkdir /vol && mount /vol'
        end
      end
   
      def describe_name
        puts_title :volume, options.vol_id
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



