require 'pp'

module Healing
  module Provider
    class EC2 < Base
      
      include Threading
      
      @@ec2 = nil
    
      def initialize options
        super options
      end
    
      def lib
        unless @@ec2
          @@ec2 = ::EC2::Base.new :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'], :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
        end
        @@ec2
      end
  
      def list
        lib.describe_instances.reservationSet.item.each do |item|
          i = item.instancesSet.item[0]
          puts "#{i.instanceId}\t#{i.instanceState.name}\t#{i.keyName}\t#{i.dnsName}\t#{i.placement.availabilityZone}\t#{i.imageId}\t#{i.amiLaunchIndex}"
        end
      end
    
      def instances options={}
        instance_list = []
        h = {}
        h[:instance_id] = options[:instance_id] if options[:instance_id]
        lib.describe_instances(h).reservationSet.item.each do |reservationSet|
          reservationSet.instancesSet.item.each do |i|
            next if options[:key] && (i.keyName != options[:key].to_s)
            next if options[:state] && (i.instanceState.name != options[:state].to_s)
            instance_list << RemoteInstance.new( :id => i.instanceId, :key => i.keyName, :address => i.dnsName, :state => i.instanceState.name )
          end
        end
        instance_list
      end

      def launch options
        response = lib.run_instances :min_count => options[:num], :max_count => options[:num], :image_id => options[:image], :key_name => options[:key]
        num = response.instancesSet.item.size
        instances = []
        response.instancesSet.item.each do |item|
          instances << RemoteInstance.new( :id => item.instanceId, :key => item.keyName, :cloud_uuid => options[:cloud_uuid], :cloud => options[:cloud] )
        end
        wait_for_addresses instances
        wait_for_ping instances
        instances
      end

      def update instance_list
        instance_ids = instance_list.map { |i| i.id }
        updated_list = instances :instance_id => instance_ids
        instance_list.each { |i| i.update_from updated_list.find { |u| u.id==i.id } }
      end

      def wait_for_addresses instances
        todo = instances.dup  #.select { |i| i.state=='pending' || i.state=='running' }
        puts_progress "Waiting for instances to acquire addresses" do
          loop do
            update todo
            done = todo.select { |i| i.address && i.address!='' }
            todo -= done
            todo.any? ? sleep(1) : break
          end
        end
      end

      def wait_for_ping instances
        instances.each_in_thread "Waiting for instances to respond", :dot => '.' do |i|
          sleep 1 until ping_port i.address
        end
      end
    
      def ping_port host, port=22
        return TCPSocket.new(host, port).is_a?(TCPSocket) rescue false
      end

      def terminate instances
        return unless instances && instances.any?
        production = ['i-7287241b','i-54b51a3d','i-8cc04be5','i-b21181db','i-3f138356']   #safety
        instances.reject! { |i| i.state=='terminated' }
        instances.each do |i|
          raise "Ups! trying to terminate production instances!" if production.include? i.id.to_s
          puts "terminating instance #{i.id}."
        end
        lib.terminate_instances( :instance_id => instances.map { |i| i.id } ) if instances.any?
      end
    
    end
  end
end