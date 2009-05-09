require 'cloud.rb'
require 'resources/resource.rb'
require 'resources/file.rb'
require 'resources/dir.rb'
require 'resources/package.rb'
require 'instance.rb'



class Heal
  
  def initialize
    @clouds = []
    @cloud = nil
  end
  
  def push_cloud cloud
    @clouds << cloud
  end

  def pop_cloud
    @prev_cloud = @clouds.pop
  end

  def prev_cloud
    @prev_cloud
  end
  
  def current_cloud
    @clouds.last
  end

  def current_depth
    @clouds.size
  end
  
end

$healer = Heal.new

def cloud name, &block
  healer.push_cloud Heal::Cloud.new(name)
  yield
  healer.pop_cloud
end

def heal
  healer.prev_cloud.heal
end

def healer
  $healer
end
