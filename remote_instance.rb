
module Healing

  class RemoteInstance

    attr_accessor :cloud_uuid, :address, :cloud, :id, :key, :state

    def initialize info
      @id = info[:id]
      @key = info[:key]
      @address = info[:address]
      @cloud_uuid = info[:cloud_uuid]
      @state = info[:state]
      @cloud = info[:cloud]
    end
    
    def update_from i
      if i
        @address = i.address
        @state = i.state
      end
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
        log command, :cmd
        ssh.exec!(command) do |ch, stream, data|
          out << data
        end
      end
      log out
      out
    end
    
    def format_block data, s=''
      #"#{address}:\n#{data}"
      
      data.split("\n").map { |line| [address,': ', s,line,"\n"]}.flatten.join
      
      #width = 60
      #data = data.split("\n").map { |line| [' '*width,' | ', line,"\n"]}.flatten
      #data[0] = [s,address].join(' ').rjust(width,' ')
      #data = data.flatten.join
      #data
    end
    
    def log str, ch = :out
      head = {:cmd => "[#{Time.now}] ", :err => "ERROR: " }
      tail = {:cmd => "\n" }
      ::File.open( "log/#{address}.log", 'a' ) { |f| f.write "#{head[ch]}#{str}#{tail[ch]}" }
    end
    
  end

end
