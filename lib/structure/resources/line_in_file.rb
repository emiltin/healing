module Healing
  module Structure
    class LineInFile < Resource
  
      def initialize parent, path, options={}
        super parent, options.merge(:path => path, :content => options[:content].strip)
      end
  
      def heal
        describe_name
        current = (::File.read(path) rescue nil)
        ::File.open(path, "a") { |f| f << "\n#{content}" } unless current =~ /^#{content}$/
      end
    
      def revert
        log "reverting file '#{path}'"
      end
 
      def describe_name
        puts_title 'line in file', path
      end
      
      def describe_settings
        puts_setting :content
      end
    
    end
  end
end

