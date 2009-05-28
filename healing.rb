
Dir.glob('utilities/*.rb') { |file| require file }     

require 'structure/base.rb'
require 'structure/resources/file'
require 'structure/resources/dir'
require 'structure/resources/package'
require 'structure/resources/gem'
require 'structure/resources/execute'
require 'structure/cloud'
require 'structure/root'
require 'structure/lingo'
require 'remoters/base'
require 'remoters/ec2'
require 'remoters/instance'
require 'remoters/volume'
require 'remoters/map'
require 'app/base'
require 'app/worker'

CLOUD_UUID_PATH = '/healing/cloud_uuid'
