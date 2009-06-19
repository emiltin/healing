module Healing
  module Structure
    class Link <  Resource
  
      def initialize parent, source, destination, options={}
        super parent, options.merge(:source => source, :destination => destination)
      end
  
      def heal
        describe_name
        run "ln -s #{source} #{destination}"
      end
    
      def describe_name
        puts_title :link, ''
      end
      
      def describe_settings
        puts_setting :source
        puts_setting :destination
      end
    
    end
  end
end

