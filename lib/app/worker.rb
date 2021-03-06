
module Healing
  module App
    class Worker < Base
    
      def initialize
        load_cloud_uuid
        Healing::Structure::Rubygem.scan_gems
        super
      end

      def load_ideal path
        super path
        @cloud = Healing::Structure::Cloud.find_cloud_with_uuid @uuid
        raise "No cloud found matching the uuid '#{@uuid}' of this instance!" unless @cloud
      end
      
      def save_cloud_uuid uuid
        raise "Cloud uuid file already exists at #{CLOUD_UUID_PATH}!" if ::File.exist?(CLOUD_UUID_PATH)
        Healing::App::Base.run_locally "echo '#{uuid}' > #{CLOUD_UUID_PATH}"
        @uuid = uuid
      end
  
      def load_cloud_uuid
        raise "Cloud uuid file not found at #{CLOUD_UUID_PATH}!" unless ::File.exist?(CLOUD_UUID_PATH)
        @uuid = ::File.read(CLOUD_UUID_PATH).strip
        raise "This instance has no cloud uuid yet!" unless @uuid
      end
  
      def heal
        puts '------------------------------------------------------------'
        puts "Healing '#{@cloud.options.name}' instance..."
        @cloud.heal_from_root
        @cloud.root.report
      end

      def diagnose
        puts '------------------------------------------------------------'
        puts "Diagnosing '#{@cloud.options.name}' instance..."
        @cloud.diagnose_from_root
        @cloud.root.report
      end
    end
  end
end
