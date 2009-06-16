
#recipe for running rails with apache and passenger (mod_rails)

#package 'apache2-mpm-prefork'
#package 'apache2-prefork-dev'
#package 'libapr1-dev'
rubygem 'rails'
rubygem 'passenger'


#we need some way of determining if it has already been  run
#when ssh'ing, the PATH is not loaded correctly?
execute 'passenger-install-apache2-module', 'echo -en "\n\n\n\n" | /var/lib/gems/1.8/bin/passenger-install-apache2-module'


line_in_file '/etc/apache2/httpd.conf', :content => <<-EOF
LoadModule passenger_module /var/lib/gems/1.8/gems/passenger-2.2.2/ext/apache2/mod_passenger.so
PassengerRoot /var/lib/gems/1.8/gems/passenger-2.2.2
PassengerRuby /usr/bin/ruby1.8
EOF
