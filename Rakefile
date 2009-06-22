require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s| 
  s.name = "healing" 
  s.version = "0.1.0" 
  s.author = "Emil tin" 
  s.email = "emil@tin.dk" 
  s.homepage = "http://tin.dk/healing" 
  s.rubyforge_project = "healing"
  s.platform = Gem::Platform::RUBY 
  s.summary = "Remote Cloud Configuration" 
  s.description = <<-EOF
    Healing is a system for cloud description and configuration.
  EOF
  s.files = FileList["{bin,tests,lib,docs}/**/*"].exclude("rdoc").to_a 
  s.require_path = "lib" 
  #s.test_file = "tests/ts_momlog.rb" 
  s.has_rdoc = true 
  s.extra_rdoc_files = ["README"] 
  #s.add_dependency("BlueCloth", ">= 0.0.4") 
end 
Gem::PackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end
