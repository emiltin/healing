require 'open3'

module Healing
  module App
    class Base
      def initialize
        load_ideal
      end
  
      def self.run_locally cmd, options={}
        Open3.popen3(cmd) do |stdin, stdout, stderr|
          out = stdout.read
          err = stderr.read
          unless options[:quiet]
            puts out unless out=='' 
            puts "stderr: #{err}" unless err==''
          end
          return out
        end
        #result  = `#{cmd}`
      end
  
      def load_ideal
        return if @cloud
        require 'ideal.rb'
        @cloud = Healing::Structure::Cloud.root
        raise "No cloud defined in ideal.rb!" unless @cloud
      end
      
    end
  end
  
end
