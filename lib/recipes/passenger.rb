#recipe for running rails with apache and passenger (mod_rails)

rubygem 'rails'
rubygem 'passenger', :version => @options.version


#TODO we need some way of determining if it has already been run
execute 'passenger-install-apache2-module', 'echo -en "\n\n\n\n" | /var/lib/gems/1.8/bin/passenger-install-apache2-module'


#TODO
#me might be able to use a run block, to determine the latest version of passenger?

file '/etc/apache2/httpd.conf', :content => <<-EOF
LoadModule passenger_module /var/lib/gems/1.8/gems/passenger-#{@options.version}/ext/apache2/mod_passenger.so
PassengerRoot /var/lib/gems/1.8/gems/passenger-#{@options.version}
PassengerRuby /usr/bin/ruby1.8
EOF
