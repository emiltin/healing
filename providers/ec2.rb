require 'rubygems'
require 'EC2'

module Healing

  class EC2 < Provider
    
    @@ec2 = nil
    
    def initialize options={}
      super options
    end
    
    def lib
      @@ec2 = ::EC2::Base.new :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'], :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY'] unless @@ec2
      @@ec2
    end
    
    def name
      'Amazon EC2'
    end
  
    def list
      lib.describe_instances.reservationSet.item.each do |item|
        i = item.instancesSet.item[0]
        puts "#{i.instanceId}\t#{i.instanceState.name}\t#{i.keyName}\t#{i.dnsName}\t#{i.placement.availabilityZone}\t#{i.imageId}\t#{i.amiLaunchIndex}"
      end
    end
    
    def instances_with_key key
      instances = []
      lib.describe_instances.reservationSet.item.each do |item|
        i = item.instancesSet.item[0]
        if (i.keyName == key.to_s) &&  (i.instanceState.name != 'terminated')
          instances << RemoteInstance.new( :id => i.instanceId, :key => i.keyName, :address => i.dnsName, :state => i.instanceState.name )
        end
      end
      instances
    end
    
    def launch_instances options
      response = lib.run_instances :image_id => options[:image], :key_name => options[:key_name]
      num = response.instancesSet.item.size
      #response.instancesSet.item[2].instanceState.name.should.equal "pending"
      #response.instancesSet.item[2].dnsName.should.be.nil
      instances = []
      response.instancesSet.item.each do |item|
        instances << RemoteInstance.new( :id => item.instanceId, :key => item.keyName, :cloud_uuid => options[:cloud_uuid] )
      end
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

    def wait_for_ping key
      printf 'Waiting for instances to respond..'
      STDOUT.flush
      todo = instances_with_key key
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


    def terminate_instances_with_key key
      raise "Can't terminate instances without key!" unless key && key!=''
      terminate_instances instances_with_key(key)
    end
    
    def terminate_instances instances
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
