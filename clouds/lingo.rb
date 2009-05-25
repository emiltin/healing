module Healing
  class Cloud
    
    class Lingo
      def initialize cloud
        @cloud = cloud
      end

      def cloud name, &block
        @cloud.subclouds << Cloud.new( {:name=>name, :root => @cloud.root, :parent => @cloud}, &block)
      end

      def instance name, &block
        @cloud.subclouds << Cloud.new( {:name=>name, :root => @cloud.root, :parent => @cloud, :instance => 1}, &block)
      end

      def instances number
        @cloud.num_instances = number
      end

      def image i
        @cloud.image = i
      end

      def provider p
        raise "You can only specify one provider!" if @cloud.provider
        @cloud.provider = Healing::Remoter.build p
    #    extend_lingo @cloud.provider
      end

      def uuid u
        @cloud.uuid = u.to_s
      end

      def file path, options={}
        @cloud.resources << Healing::File.new(path, @cloud, options)
      end

      def dir path, options={}
        @cloud.resources << Healing::Dir.new(path, @cloud, options)
      end

      def package name, options={}
        @cloud.resources << Healing::Package.new(name, @cloud, options)
      end

      def rubygem name, options={}
        @cloud.resources << Healing::Gem.new(name, @cloud, options)
      end

      def execute name, command, options={}
        @cloud.resources << Healing::Execute.new(name, command, @cloud, options)
      end

      def recipe path
        instance_eval ::File.read("recipes/#{path}.rb")
      end

      def key path
        @cloud.key = path
      end
      
      def volume vol_hash
        raise "You cannot attach volumes to a cloud with more than one instance!" if @cloud.num_instances>1
        @cloud.volumes.merge! vol_hash
      end
             
      def extend_lingo guest
        k = "#{guest.class.name}::Lingo"
        self.class.class_eval "include #{k}"
      end
      
    end

  end

end
