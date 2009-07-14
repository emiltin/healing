module Healing
  module Structure
    class Volume < Resource
      
      def initialize parent, vol_id, o={}
        super parent, o.merge(:vol_id=>vol_id)
        nearest_cloud.volumes << self
        the_dev = options.device
        the_path = options.path
        lingo self do
          package 'xfsprogs'
          line_in_file '/etc/fstab', :content => "#{the_dev} #{the_path} xfs noatime 0 0\n"
          dir the_path
        end
      end
      
      def healed?
        #run df, to get some info we can parse to verify that the volume is mounted
        df = run "df #{options.path}", :quiet => true
        df =~ /^#{options.device}/ && df =~ /#{options.path}$/
      end
      
      def heal
        super
        run "mount #{options.path}" unless healed?
      end
      
      def defaults
        { :device => '/dev/sdh', :path => '/vol' }
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



