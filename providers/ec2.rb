module Healing
  module Provider
    class EC2 < Base
    
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
    
      def instances options
        instances = []
        lib.describe_instances.reservationSet.item.each do |item|
          i = item.instancesSet.item[0]
          next if options[:key] && (i.keyName != options[:key].to_s)
          next if options[:state] && (i.instanceState.name != options[:state].to_s)
          instances << RemoteInstance.new( :id => i.instanceId, :key => i.keyName, :address => i.dnsName, :state => i.instanceState.name )
        end
        instances
      end
    
      def launch options
        response = lib.run_instances :instances => options[:num], :image_id => options[:image], :key_name => options[:key]
        num = response.instancesSet.item.size
        instances = []
        response.instancesSet.item.each do |item|
          instances << RemoteInstance.new( :id => item.instanceId, :key => item.keyName, :cloud_uuid => options[:cloud_uuid], :cloud => options[:cloud] )
        end
        wait_for_addresses instances
        wait_for_ping instances
        instances   #note that instances will take a while to launch and boot
      end

      def wait_for_addresses instances
        printf 'Waiting for instances to acquire addresses..'
        STDOUT.flush
        todo = instances.dup
        done = []     
        120.times do  #keep trying for 10 minutes
          response = lib.describe_instances
          todo.each do |instance|
            item = response.reservationSet.item.find { |i| i.instancesSet.item[0].instanceId==instance.id }
            raise "No instance running with id #{instance.id}!" unless item
            info = item.instancesSet.item[0]
            if info.dnsName && info.dnsName!=''
              instance.address = info.dnsName       #store address in RemoteInstance object
              done << instance
            else
              printf '.'
              STDOUT.flush
              sleep 5
              break
            end
          end
          todo -= done
          done = []
          if todo.empty?
            puts ' ready.'
            return
          end
        end
        raise "Instances with key #{key} didn't acquire an address after #{timeout} seconds."
      end

      def wait_for_ping instances
        printf 'Waiting for instances to respond..'
        STDOUT.flush
        todo = instances
        done = []
        120.times do  #keep trying for 10 minutes
          todo.each do |instance| 
            done << instance if ping_port instance.address
          end
          todo -= done
          done = []
          if todo.empty?
            puts ' ready.'
            return
          end
          printf '.'
          STDOUT.flush
          sleep 5
        end
        puts ''
        raise "#{todo.size} instances with key #{key} didn't doesn't respond!"
      end
    
      def ping_port host, port=22
        return TCPSocket.new(host, port).is_a?(TCPSocket) rescue false
      end

      def terminate instances
        return unless instances && instances.any?
        production = ['i-7287241b','i-54b51a3d','i-8cc04be5','i-b21181db','i-3f138356']   #safety
        instances.reject! { |i| i.state!='running' }
        instances.each do |i|
          raise "Ups! trying to terminate production instances!" if production.include? i.id.to_s
          puts "terminating instance #{i.id}."
        end
        lib.terminate_instances( :instance_id => instances.map { |i| i.id } ) if instances.any?
      end
    
    end
  end
end