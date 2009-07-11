require 'open3'

module Healing
  module App
    class Base
      def initialize
      end
  
      def self.run_locally cmd, options={}
        Open3.popen3(cmd) do |stdin, stdout, stderr|
          out = stdout.read
          err = stderr.read
          unless options[:quiet]
            puts out unless out=='' 
          end
          raise err unless err==''
          return out
        end
        #result  = `#{cmd}`
      end
  
      def load_ideal path
        return if @cloud
        raise "Ideal file not found: #{path}" unless ::File.exists? path
        require path
        @cloud = Healing::Structure::Cloud.root
        raise "No cloud defined in ideal.rb!" unless @cloud
      end
      
    end
  end
  
end
