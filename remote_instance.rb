
module Healing

  class RemoteInstance

    attr_accessor :cloud_uuid, :address, :cloud
    attr_reader :id, :key, :state

    def initialize info
      @id = info[:id]
      @key = info[:key]
      @address = info[:address]
      @cloud_uuid = info[:cloud_uuid]
      @state = info[:state]
      @cloud = info[:cloud]
    end

    def fetch_cloud_uuid
      @cloud_uuid = execute("cat #{CLOUD_UUID_PATH}", :quiet => true).strip
    end
    
    def belong cloud
      @cloud = cloud
      execute "mkdir /healing && echo '#{@cloud.uuid}' > /healing/cloud_uuid", :quiet => true
    end
    
    def execute command, options = {}
      ssh_options = { :keys => [@cloud.root.key_path], :auth_methods => 'publickey', :paranoid => false }
      out = ''
      Net::SSH.start( address, 'root', ssh_options) do |ssh|  
        ssh.exec!(command) do |ch, stream, data|
          if stream == :stdout
            puts data.split("\n").map { |line| " #{address}  |  #{line}" } unless options[:quiet]
            out << data
          else
            $stderr.puts "  [#{address}] ERROR: #{data}"# unless options[:quiet]
          end
        end
      end
      out
    end

  end

end
