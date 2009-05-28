module Healing
  module Structure
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

        def remoter p
          raise "You can only specify one remoter!" if @cloud.remoter
          @cloud.remoter = Healing::Remoter::Base.build p
          #    extend_lingo @cloud.remoter
        end

        def uuid u
          @cloud.uuid = u.to_s
        end

        def file path, options={}
          @cloud.resources << Healing::Structure::File.new(path, @cloud, options)
        end

        def dir path, options={}
          @cloud.resources << Healing::Structure::Dir.new(path, @cloud, options)
        end

        def package name, options={}
          @cloud.resources << Healing::Structure::Package.new(name, @cloud, options)
        end

        def rubygem name, options={}
          @cloud.resources << Healing::Structure::Gem.new(name, @cloud, options)
        end

        def execute name, command, options={}
          @cloud.resources << Healing::Structure::Execute.new(name, command, @cloud, options)
        end

        def recipe path
          instance_eval ::File.read("recipes/#{path}.rb")
        end

        def key path
          @cloud.key = path
        end

        def volume id, options
          raise "You cannot attach volumes to a cloud with more than one instance!" if @cloud.num_instances>1
          h = { :volume_id => id }.merge(options)
          @cloud.volumes << h
#          @cloud.volumes << Healing::Remoter::Volume.new(:id => id, :device => options[:device])
        end

        def extend_lingo guest
          k = "#{guest.class.name}::Lingo"
          self.class.class_eval "include #{k}"
        end

      end

    end
  end
end
