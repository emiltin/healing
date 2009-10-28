
module Healing
  module Remoter
    class EC2 < Base

      include Threading

      @@ec2 = nil

      module Lingo
        def volume id
          puts "....attaching EBS volume #{id}"
          puts @cloud.remoter.name   #we have access to the cloud and the ec2 provider object
        end
      end

      def initialize options
        super options
      end

      def ec2
        unless @@ec2
          require 'rubygems'
          require 'net/ssh'
          require 'EC2'
          @@ec2 = ::EC2::Base.new :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'], :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
        end
        @@ec2
      end

      def list
        ec2.describe_instances.reservationSet.item.each do |item|
          i = item.instancesSet.item[0]
          puts "#{i.instanceId}\t#{i.instanceState.name}\t#{i.keyName}\t#{i.dnsName}\t#{i.placement.availabilityZone}\t#{i.imageId}\t#{i.amiLaunchIndex}"
        end
      end

      def instances options={}
        h = {}
        h[:instance_id] = options[:instance_id] if options[:instance_id]
        info = ec2.describe_instances(h)
        return [] unless info.reservationSet
        instance_list = []
        info.reservationSet.item.each do |reservationSet|
          reservationSet.instancesSet.item.each do |i|
            next if options[:key] && (i.keyName != options[:key].to_s)
            next if options[:state] && (i.instanceState.name != options[:state].to_s)
            instance_list << Healing::Remoter::Instance.new( :id => i.instanceId, :key => i.keyName, :address => i.dnsName, :state => i.instanceState.name )
          end
        end
        instance_list
      end

      def launch options
        response = ec2.run_instances :min_count => options[:num], :max_count => options[:num], :image_id => options[:image], :key_name => options[:key], :availability_zone => options[:availability_zone]
        num = response.instancesSet.item.size
        instances = []
        response.instancesSet.item.each do |item|
          instances << Healing::Remoter::Instance.new( :id => item.instanceId, :key => item.keyName, :cloud_uuid => options[:cloud_uuid], :cloud => options[:cloud] )
        end
        instances
      end

      def terminate instances
        return unless instances && instances.any?
        instances.reject! { |i| i.state=='terminated' }
        instances.each do |i|
          puts "terminating instance #{i.id}."
        end
        ec2.terminate_instances( :instance_id => instances.map { |i| i.id } ) if instances.any?
      end

      def volumes options={}
        h = {}
        h[:volume_id] = options[:volume_id] if options[:volume_id]
        info = ec2.describe_volumes(h)
        return [] unless info.volumeSet
        volume_list = []
        info.volumeSet.item.each do |i|
          next if options[:status] && (i.status != options[:status].to_s)
          h = { :id => i.volumeId, :status => i.status }
          if i.attachmentSet
            h.merge!( {:attachment => i.attachmentSet.item[0].status, 
                        :device => i.attachmentSet.item[0].device,
                        :instance_id => i.attachmentSet.item[0].instanceId} )
          end
          volume_list << Healing::Remoter::Volume.new(h)
        end
        volume_list
      end
      
      def attach_volume options
        ec2.attach_volume options
      end
    end
  end
  end