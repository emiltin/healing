
module Healing
  module App
    class Admin < Base
  
      def describe
  #      Healing::Structure::Rubygem.scan_gems
        @cloud.describe :recurse => true
      end
  
      def compile
        @cloud.compile
        @cloud.preflight
      end
  
      def upload
        @cloud.install
      end

      def terminate
        @cloud.terminate
      end
  
      def heal
        @cloud.heal_remote
        @cloud.report_remote
      end

      def diagnose
        @cloud.diagnose_remote
        @cloud.report_remote
      end

      def prune
        @cloud.prune
      end

      def scan
        @cloud.show_instances
      end
    
      def volumes
        @cloud.show_volumes
      end
    
    end
  end
end
