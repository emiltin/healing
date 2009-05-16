require 'threading'
require 'resources/resource'
require 'resources/file'
require 'resources/dir'
require 'resources/package'
require 'resources/cloud'
require 'resources/root_cloud'
require 'remote_instance'
require 'actors/healer'
require 'actors/instance'
require 'providers/provider'
require 'providers/ec2'
require 'map'

CLOUD_UUID_PATH = '/healing/cloud_uuid'
