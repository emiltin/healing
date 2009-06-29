module Healing
  BASE = File.dirname( File.dirname(__FILE__) )
  
  Dir.glob(BASE+'/lib/utilities/*.rb') { |file| require file }     
  Dir.glob(BASE+'/lib/core/*.rb') { |file| require file }     


  #note: the order of the requires below is significant to avoid load errors

  require BASE+'/lib/structure/base.rb'
  require BASE+'/lib/structure/resources/resource'
  require BASE+'/lib/structure/cloud'
  require BASE+'/lib/structure/instance'
  require BASE+'/lib/structure/root'
  require BASE+'/lib/structure/volume'
  require BASE+'/lib/structure/resources/recipe'
  require BASE+'/lib/structure/resources/run'
  require BASE+'/lib/structure/resources/file'
  require BASE+'/lib/structure/resources/link'
  require BASE+'/lib/structure/resources/line_in_file'
  require BASE+'/lib/structure/resources/dir'
  require BASE+'/lib/structure/resources/package'
  require BASE+'/lib/structure/resources/service'
  require BASE+'/lib/structure/resources/rake'
  require BASE+'/lib/structure/resources/rubygem'
  require BASE+'/lib/structure/resources/execute'
  require BASE+'/lib/structure/resources/repo'
  require BASE+'/lib/structure/resources/git_repo'
  require BASE+'/lib/remoters/base'
  require BASE+'/lib/remoters/ec2'
  require BASE+'/lib/remoters/instance'
  require BASE+'/lib/remoters/volume'
  require BASE+'/lib/remoters/map'
  require BASE+'/lib/app/base'
  require BASE+'/lib/app/worker'
  require BASE+'/lib/app/provisioner'
  require BASE+'/lib/app/bootstrapper'


  Healing::Structure::Rubygem.load_dependencies BASE+'/lib/gem_dependencies.yml'


  Dir.glob(BASE+'/lib/structure/resources/plugins/*.rb') { |file| require file }     

  CLOUD_UUID_PATH = '/healing/cloud_uuid'



  require BASE+'/lib/app/admin'
  require BASE+'/lib/app/worker'
end
