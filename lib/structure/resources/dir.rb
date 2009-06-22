module Healing
  module Structure
    class Dir < Resource

      def initialize parent, path, options={}
        super parent, options.merge(:path => path)
      end

      def defaults
        { :mode => '0777' }
      end

      def heal
        describe_name
        if source
          run "cp -R #{source} #{path}"
        else
          run "mkdir -p #{path}"
        end  
        run "chmod '#{mode}' #{path}" if mode
      end

      def revert
        @cloud.log "reverting dir '#{path}'"
        #      run "rm -rf #{path}"
      end
      
      def describe_name
        puts_title :dir, path
      end
      
      def describe_settings
        puts_setting :mode if mode
      end


    end
  end
end