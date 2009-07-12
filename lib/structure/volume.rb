module Healing
  module Structure
    class Volume < Resource
      
      def initialize parent, vol_id, o={}
        super parent, o.merge(:vol_id=>vol_id)
        nearest_cloud.volumes << self
        lingo self do
          package 'xfsprogs'
        end
      end
      
      def healed?
        ::File.exists? '/vol'
      end
      
      def heal
        unless healed?
          run "echo \"#{options.device} /vol xfs noatime 0 0\" >> /etc/fstab"
          run 'mkdir /vol && mount /vol'
        end
        true  
      end
      
      def defaults
        { :device => '/dev/sdh' }
      end
      
      def name
        options.vol_id
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



