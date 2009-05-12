require 'rubygems'
require 'EC2'

class Healing
  class CloudProvider
  
    def initialize options={}
      @options = options
    end
  
    def run
      #@ec2.run_instances :image_id => "ami-bf5eb9d6", :key_name => 'testpair', :zone => 'us-east-1a'
    end
  
    def terminate
    end
  
    def describe
    end
  
  end


  class EC2Provider < CloudProvider
  
    def initialize options={}
      @ec2 = ::EC2::Base.new :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'], :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
      super options
    end
  
  
    def describe
      @ec2.describe_instances.reservationSet.item.each do |item|
        i = item.instancesSet.item[0]
        puts "#{i.instanceId}\t#{i.instanceState.name}\t#{i.keyName}\t#{i.dnsName}\t#{i.placement.availabilityZone}\t#{i.imageId}\t#{i.amiLaunchIndex}"
      end
    end
    
    def instances_with_key key
      instances = []
      @ec2.describe_instances.reservationSet.item.each do |item|
        i = item.instancesSet.item[0]
        if i.keyName == key.to_s
          instances << InstanceInfo.new( :id => i.instanceId, :key => i.keyName, :address => i.dnsName )
        end
      end
      instances
    end
    
  end
end
