module Healing
  module Structure
    class LineInFile < Resource
  
      def initialize parent, path, opt={}
        super parent, opt.merge(:path => path, :content => opt[:content].strip)
      end
  
      def heal
        describe_name
        current = (::File.read(options.path) rescue nil)
        unless current =~ /^#{options.content}$/
          ::File.open(options.path, "a") do |f| 
            f << "\n" unless current[-1..-1]=="\n"
            f << "#{options.content.to_s}\n"         
          end
        end
      end
      
      def type
        "line in file"
      end
      
      def name
        "#{options.path}"
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

