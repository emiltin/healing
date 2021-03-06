
module Healing
  module Remoter
    class Base
      attr_reader :name

      def self.build name
        case name.to_s.downcase
        when "ec2"
          Healing::Remoter::EC2.new :name => name
        else
          raise "Unknown Remoter '#{name}'."
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

      def volumes options
      end

      def attach_volume options
      end

      def detach_volume options
      end

      def arrange_volumes list
        cur = volumes
        list.reject! do |i|
          cur.find { |c| c.id==i[:volume_id] && c.instance_id==i[:instance_id] } != nil
        end
        if list.any?
          puts "Attaching #{list.size} volume(s)."
          list.each { |options| attach_volume options }
        end
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
        instances.each_in_thread "Waiting for responses" do |i|
          sleep 1 until ping_port i.address
        end
      end

      def ping_port host, port=22
        return TCPSocket.new(host, port).is_a?(TCPSocket) rescue false
      end
    end

  end
end