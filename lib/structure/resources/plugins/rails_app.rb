module Healing
  module Structure
    class RailsApp < Resource

      def initialize parent, name, o
        super parent, o.merge(:name => name)
        
        lingo self, options.to_hash do        #pass on options to the lingo block
          path = options.name
          recipe 'passenger', :version => '2.2.4' #TODO would be nicer to read the rails env file and use that to determine which rails version to install, or if it's vendored
          git_repo path, :url => options.repo, :user => 'www-data', :group => 'www-data'
          
          run 'choose DB', :description => "read rails config and install the right db package", :path => path, :environment => options.environment do
            config = YAML.load_file("#{options.path}/config/database.yml") 
            adapter = config[options.environment.to_s]['adapter']
            mappings = { 'mysql' => 'mysql', 'sqlite3' => 'sqlite3-ruby' }
            gem_name = mappings[ adapter ]
            print "Inspecting the rails config...  "
            if gem_name
              puts "Using db adapter '#{adapter}'"
              run_recipe { rubygem gem_name }
            else
              msg = "Unkown db adater!"
              puts msg
              msg
            end
          end

          the_options = options

          service 'apache2' do
            while_stopped do
              #remove default virtual host
              file '/etc/apache2/sites-enabled/000-default', :remove => true

              #add virtual host
              file "/etc/apache2/sites-enabled/#{the_options.name}", :content => <<-EOF
<Directory "/#{the_options.name}">
 Options FollowSymLinks
 AllowOverride None
 Order allow,deny
 Allow from all
</Directory>

<VirtualHost *:80>
 ServerName localhost
 DocumentRoot /#{the_options.name}/public
 RailsEnv #{the_options.environment}
</VirtualHost>
EOF
            end
          end
        end
      end
      
      def defaults
        { :environment => :production }
      end
      
      def heal
        describe_name
        super
      end
      
      def type
        "rails app"
      end
      

      def ref
        "#{options.name} rails app"
      end

      def describe_name
        puts_title :rails_app, options.name
      end
      
      def describe_settings
        puts_setting :repo
        puts_setting :environment
      end


    end
  end
end

