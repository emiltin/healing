module Healing
  module Structure
    class LineInFile < Resource
  
      def initialize parent, path, opt={}
        super parent, opt.merge(:path => path, :content => opt[:content].strip)
      end
  
      def heal
        describe_name
        current = (::File.read(options.path) rescue nil)
        ::File.open(options.path, "a") { |f| f << "\n#{options.content}" } unless current =~ /^#{options.content}$/
      end
    
      def describe_name
        puts_title 'line in file', options.path
      end
      
      def describe_settings
        puts_setting :content
      end
    
    end
  end
end

