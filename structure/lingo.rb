module Healing
  module Structure
    class Cloud

      class Lingo
        def initialize parent
          @parent = parent
        end

        def cloud name, &block
          Cloud.new( @parent, {:name=>name, :root => @parent.root}, &block)
        end

        def instance name, &block
          Instance.new( @parent, {:name=>name, :root => @parent.root, :num_instances => 1}, &block)
        end

        def instances number
          @parent.num_instances = number
        end

        def image i
          @parent.image = i
        end

        def remoter p
          raise "You can only specify one remoter!" if @parent.remoter
          @parent.remoter = Healing::Remoter::Base.build p
          #    extend_lingo @parent.remoter
        end

        def uuid u
          @parent.uuid = u.to_s
        end

        def file path, options={}
          Healing::Structure::File.new(@parent, path, options)
        end

        def dir path, options={}
          Healing::Structure::Dir.new(path, @parent, options)
        end

        def package name, options={}
          Healing::Structure::Package.new(@parent, name, options)
        end

        def rubygem name, options={}
          Healing::Structure::Gem.new(name, @parent, options)
        end

        def execute name, command, options={}
          Healing::Structure::Execute.new(name, command, @parent, options)
        end

        def recipe path
          instance_eval ::File.read("recipes/#{path}.rb")
        end

        def key path
          @parent.key = path
        end

        def volume id, options
          Healing::Structure::Volume.new(@parent, id, options)
        end

        def extend_lingo guest
          k = "#{guest.class.name}::Lingo"
          self.class.class_eval "include #{k}"
        end

      end

    end
  end
end
