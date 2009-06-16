
Dir.glob('utilities/*.rb') { |file| require file }     
Dir.glob('core/*.rb') { |file| require file }     




require 'structure/base.rb'
require 'structure/resources/resource'
require 'structure/resources/recipe'
require 'structure/resources/file'
require 'structure/resources/line_in_file'
require 'structure/resources/dir'
require 'structure/resources/package'
require 'structure/resources/service'
require 'structure/resources/rubygem'
require 'structure/resources/execute'
require 'structure/resources/repo'
require 'structure/resources/git_repo'
require 'structure/cloud'
require 'structure/instance'
require 'structure/root'
require 'structure/volume'
require 'remoters/base'
require 'remoters/ec2'
require 'remoters/instance'
require 'remoters/volume'
require 'remoters/map'
require 'app/base'
require 'app/worker'
require 'app/provisioner'
require 'app/bootstrapper'

#File.dirname(__FILE__)+"/
Healing::Structure::Rubygem.load_dependencies 'gem_dependencies.yml'


Dir.glob('structure/resources/plugins/*.rb') { |file| require file }     

CLOUD_UUID_PATH = '/healing/cloud_uuid'

