module Healing
  module Structure
    class Dir < Resource

      def initialize parent, path, o={}
        super parent, o.merge(:path => path)
      end

      def defaults
        { :mode => 0777 }
      end
      
      def healed?
        return false unless ::File.exists?(options.path) && ::File.directory?(options.path)
        return true unless options.mode?
        (::File.stat(options.path).mode & 0777) == options.mode    #only compare lower tre octal digits
      end

      def diagnose
        return "Directory needs to be created" unless ::File.exists?(options.path) && ::File.directory?(options.path)
        return "Mode needs to be adjusted" if options.mode? && ((::File.stat(options.path).mode & 0777) != options.mode)   #only compare lower tre octal digits
      end
      
      def heal
        FileUtils.makedirs options.path unless ::File.exists? options.path
        FileUtils.chmod options.mode, options.path if options.mode
      end
      
      def ref
        "#{options.path} dir"
      end
      
      def name
        options.path
      end

      def format_title
        options.path
      end

      def describe_name
        puts_title :dir, options.path
      end
      
      def describe_settings
        puts_setting :mode if options.mode
      end


    end
  end
end