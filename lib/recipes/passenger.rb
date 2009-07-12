#recipe for running rails with apache and passenger (mod_rails)

rubygem 'rails'
rubygem 'passenger', :version => @options.version

base = "/var/lib/gems/1.8/gems/passenger-#{@options.version}"

run 'build passenger module', :description => "run passenger install scripts unless already build" do
  if ::File.exists? "#{base}/ext/apache2/mod_passenger.so"
    puts "Module already build."
  else
    run_recipe do
      execute 'passenger-install-apache2-module', 'echo -en "\n\n\n\n" | /var/lib/gems/1.8/bin/passenger-install-apache2-module'
    end
    "Installed passenger apache2 module."
  end
end


#TODO
#me might be able to use a run block, to determine the latest version of passenger?

file '/etc/apache2/httpd.conf', :content => <<-EOF
LoadModule passenger_module #{base}/ext/apache2/mod_passenger.so
PassengerRoot #{base}
PassengerRuby /usr/bin/ruby1.8
EOF
