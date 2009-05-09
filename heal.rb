require 'resources/resource.rb'
require 'resources/file.rb'
require 'resources/dir.rb'
require 'resources/package.rb'
require 'resources/cloud.rb'




def cloud name, &block
  $cloud = Heal::Cloud.new :healing, nil, &block
end

def heal
  $cloud.heal
end
