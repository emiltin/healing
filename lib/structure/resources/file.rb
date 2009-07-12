module Healing
  module Structure
    class File < Resource
  
      def initialize parent, path, options={}
        super parent, options.merge(:path => path)
      end
  
      def defaults
        { :mode => 0777 }
      end

      def healed?
        return false unless ::File.file?(options.path)
        f = ::File.new options.path
        return false if options.mode? && ((f.stat.mode & 0777) != options.mode)    #only compare lower tre octal digits
        return false if options.content? && (::File.read(options.path) != options.content)
        true
      end
      
      def heal
        if options.remove?
          FileUtils.rm options.path if ::File.exists? options.path
        else
          ::File.open(options.path,'w') {|f| f.write options.content }
          FileUtils.chmod options.mode, options.path if options.mode
        end
      end
 
      def name
        #::File.basename options.path
        options.path
      end

      def ref
        "#{name} file"
      end

      def format_title
        options.path
      end

      def describe_name
        s = options.path
        s += " (remove)" if options.remove?
        puts_title :file, s
      end
      
      def describe_settings
        if options.remove?
          puts_setting :remove
        else
          puts_setting :content if options.content
          puts_setting :mode if options.mode
        end
      end
    
    end
  end
end

