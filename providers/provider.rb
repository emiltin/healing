
module Healing
  module Provider

    class Base
      attr_reader :name
    
      def self.build name
        case name.to_s.downcase
        when "ec2"
          Healing::Provider::EC2.new :name => name
        else
          raise "Unknown provider '#{name}'."
        end
      end
    
      def initialize options
        @name = options[:name]
      end
  
      def launch options
      end
  
      def terminate instances
      end
  
      def instances options
      end

      def update instance_list
        instance_ids = instance_list.map { |i| i.id }
        updated_list = instances :instance_id => instance_ids
        instance_list.each { |i| i.update_from updated_list.find { |u| u.id==i.id } }
      end

      def wait_for_addresses instances
        todo = instances.dup  #.select { |i| i.state=='pending' || i.state=='running' }
        puts_progress "Waiting for addresses" do
          loop do
            update todo
            done = todo.select { |i| i.address && i.address!='' }
            todo -= done
            todo.any? ? sleep(1) : break
          end
        end
      end

      def wait_for_ping instances
        instances.each_in_thread "Waiting for responses", :dot => '.' do |i|
          sleep 1 until ping_port i.address
        end
      end
    
      def ping_port host, port=22
        return TCPSocket.new(host, port).is_a?(TCPSocket) rescue false
      end
    end

  end
  
end