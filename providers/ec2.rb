require 'rubygems'
require 'EC2'

class Healing

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
          instances << InstanceInfo.new( :id => i.instanceId, :key => i.keyName, :address => i.dnsName, :state => i.instanceState.name )
        end
      end
      instances
    end
    
    def launch_instances options
      response = lib.run_instances :image_id => options[:image], :key_name => options[:key_name]
      #response.instancesSet.item[2].instanceState.name.should.equal "pending"
      #response.instancesSet.item[2].dnsName.should.be.nil
      InstanceInfo.new( :id => response.instancesSet.item[0].instanceId, :key => response.instancesSet.item[0].keyName )
      
      #it will be pending for a while, and not not have an address yet...
    end
    
    def terminate id
      production = ['i-7287241b','i-54b51a3d','i-8cc04be5','i-b21181db','i-3f138356']
      raise "UPS trying to terminate production instances!" if production.includes? id.to_s
    end
    
  end
end
