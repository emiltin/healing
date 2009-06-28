module Healing
  module Structure
    class RailsApp < Resource

      def initialize parent, name, o
        super parent, o.merge(:name => name)
        
        lingo self, options.to_hash do        #pass on options to the lingo block
          recipe 'passenger', :version => '2.2.4'
          git_repo "/#{options.name}", :url => options.repo, :user => 'www-data', :group => 'www-data'
          
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
      
      def heal
        describe_name
        super
      end
      
      def describe_name
        puts_title :rails_app, options.name
      end
      
      def describe_settings
        puts_setting :repo
        puts_setting :env
      end


    end
  end
end

