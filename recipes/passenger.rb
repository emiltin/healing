#recipe for running rails with apache and passenger (mod_rails)

rubygem 'rails'
rubygem 'passenger'


#TODO we need some way of determining if it has already been run
execute 'passenger-install-apache2-module', 'echo -en "\n\n\n\n" | /var/lib/gems/1.8/bin/passenger-install-apache2-module'



#FIXME using the passenger version nr is 
line_in_file '/etc/apache2/httpd.conf', :content => <<-EOF
LoadModule passenger_module /var/lib/gems/1.8/gems/passenger-#{@options.version}/ext/apache2/mod_passenger.so
PassengerRoot /var/lib/gems/1.8/gems/passenger-#{@options.version}
PassengerRuby /usr/bin/ruby1.8
EOF
