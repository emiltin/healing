module Healing
  module Structure
    class Cloud < Base

      attr_accessor :subclouds, :uuid, :name, :children, :num_instances, :root, :volumes

      class << self
        attr_accessor :root
      end

      @@clouds = []
      def self.clouds
        @@clouds
      end

      def initialize parent, options, &block
        raise "Clouds must be created with a block!" unless block
        @subclouds = []
        super parent, options
        @parent.subclouds << self if @parent
        @root = options[:root]
        @parent = options[:parent]
        @name = options[:name]
        @volumes = []
        @num_instances = options[:num_instances]
        Lingo.new(self).instance_eval &block
        validate
        Cloud.clouds << self 
        @root.clouds << self
      end
      
      def my_instances
        root.map.instances.select { |i| i.cloud_uuid==@uuid }
      end
      
      def find_cloud cloud_uuid
        return self if cloud_uuid==@uuid
        @subclouds.each do |c| 
          r = c.find_cloud cloud_uuid
          return r if r
        end
        nil
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
        raise "Cloud uuid not set in '#{name}'" unless @uuid || !@num_instances
      end

      def root?
        false
      end

      def describe options={}
        log "cloud: #{@name}"
        describe_settings
        super options
      end

      def describe_settings
        log "uuid: #{@uuid}", 1 if @uuid
        log "instances: #{@num_instances}", 1 if @num_instances
  #      log "volumes: #{@volumes.inspect}" if @volumes.any?
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
        super
      end

      def get_uuid
        @uuid
      end

    end
  end
end



def cloud name, &block
  Healing::Structure::Root.new( {:name=>name}, &block )
end

