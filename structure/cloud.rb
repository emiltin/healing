module Healing
  module Structure
    class Cloud < Base

      attr_accessor :resources, :uuid, :name, :depth, :subclouds, :num_instances, :root, :volumes

      class << self
        attr_accessor :root
      end

      @@clouds = []
      def self.clouds
        @@clouds
      end

      def initialize options, &block
        raise "Clouds must be created with a block!" unless block
        @root = options[:root]
        @parent = options[:parent]
        @name = options[:name]
        @resources = []
        @volumes = []
        @subclouds = []
        @depth = @parent ? @parent.depth+1 : 0
        Lingo.new(self).instance_eval &block
        validate
        Cloud.clouds << self 
      end
      
      def my_instances
        root.instances.select { |i| i.cloud_uuid==@uuid }
      end
      
      def arm
        cur = my_instances.size   
        n = @num_instances - cur
        n.times { root.armed << self } if n>0
        @subclouds.each { |c| c.arm } 
      end

      def prune
        pruning = []
        cur = my_instances
        n = cur.size - @num_instances
        n.times { pruning << cur.shift } if n>0   #pick instances to terminate
        @subclouds.each { |c| pruning.concat c.prune }
        pruning
      end

      def validate
        raise "Cloud uuid not set in '#{name}'" unless @uuid
      end

      def root?
        false
      end

      def describe options={}
        log "cloud: #{@name}", -1
        describe_settings
        @resources.each { |item| item.describe options }
        @subclouds.each { |item| item.describe options } if options[:recurse]
      end

      def describe_settings
        log "uuid: #{@uuid}"
        log "instances: #{@num_instances}" if @num_instances
        log "volumes: #{@volumes.inspect}" if @volumes.any?
      end

      def remoter
        root.remoter
      end

      def image
        root.image
      end

      def self.find_cloud_with_uuid uuid
        @@clouds.find { |c| c.uuid==uuid }
      end

      def key= key
        raise "Error in cloud '#{@name}': The key can only be set in the root cloud!" unless @depth==0
        @key = key
      end

      def key_name
        ::File.basename @key, ".*"
      end

      def key_path
        @key
      end

      def heal
        log "cloud: #{@name}", -1
        @resources.each { |item| item.heal }
      end

      def log msg, level=0
        puts '   '*(@depth+1+level) + msg
      end

      def get_uuid
        @uuid
      end
                  
      def volumes_hash
        #TODO this method is ugly
        volumes = []
        my_instances.each do |instance|
          @volumes.each { |v| volumes << {:volume_id => v[:volume_id], :instance_id => instance.id, :device => v[:device]} }
        end
        @subclouds.each { |c| volumes.concat c.list_volumes } 
        volumes
      end


    end
  end
end



def cloud name, &block
  Healing::Structure::Root.new( {:name=>name}, &block )
end
