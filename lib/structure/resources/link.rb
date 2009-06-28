module Healing
  module Structure
    class Link <  Resource
  
      def initialize parent, source, destination, o={}
        super parent, o.merge(:source => source, :destination => destination)
      end
  
      def heal
        describe_name
        run "ln -s #{options.source} #{options.destination}"
      end
    
      def describe_name
        puts_title :link, "#{options.destination} --> #{options.source}"
      end
      
      def describe_settings
        puts_setting :source
        puts_setting :destination
      end
    
    end
  end
end

