require 'healing'
require 'providers/provider.rb'
require 'providers/ec2.rb'

module Healing
  class Initiator < Healer
  
    def load_ideal
      super
      @provider = Healing::Provider.build @cloud.provider
    end
  
    def describe
      @cloud.describe :recurse => true
    end
  
    def install
      puts 'installing'
      #it seems ssh here doesn't work if we use ~ in the path?
      Healing::Healer.run_locally "rsync -e 'ssh -i #{@cloud.key_path}' -ar /Users/emiltin/Desktop/healing/ root@#{addr}:/healing"
    end
  
    def addr
      #should really ssh to to all instances.....
      addr = @map.instances.first.address if @map && @map.instances.any? 
      raise "Empty address!" unless addr
      addr
    end
  
    def start
      map
      provision
      bootstrap
      install
      heal
    end
  
    def provision
      instances = launch_cloud @cloud
      @provider.wait_for_addresses instances
      @provider.wait_for_ping @cloud.key_name
      send_cloud_uuids instances
      @map.update
    end
  
  
    def launch_cloud cloud
      ideal = cloud.instances
      cur = @map.instances_in_cloud(cloud.uuid).size
    
      puts "Launching cloud #{cloud.uuid}"
      #puts "ideal: #{ideal}"
      #puts "current: #{cur}"
    
      if ideal>cur
        num = ideal - cur
        puts "Launching #{num} instance(s)."
        instances = @provider.launch_instances :instances => num, :image => @cloud.image, :key_name => @cloud.key_name, :cloud_uuid => @cloud.uuid 
      end
      cloud.subclouds.each { |c| instances << launch_cloud(c) }    #traverse cloud hierachy 
      instances 
    end
  
    def send_cloud_uuids instances
      puts 'Organizing cloud instances.'
      instances.each { |i| i.send_cloud_uuid @cloud }
    end
  
    def bootstrap
    end

    def terminate
      puts 'Terminating cloud.'
      @provider.terminate_instances_with_key @cloud.key_name
    end
  
    def heal
      map
      puts "\nHealing instance #{addr}."
  #    install   #should only upload ideal.rb and recipes...
      Healing::Healer.run_locally "ssh -i #{@cloud.key_path} root@#{addr} \"cd /healing && bin/heal-local\""
    end

    def map
      @map =  Healing::Map.new @cloud, @provider unless @map
    end
    
    def show
      map
      @map.show
    end

  end
end
