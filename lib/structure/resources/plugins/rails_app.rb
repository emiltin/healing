module Healing
  module Structure
    class RailsApp < Resource

      def initialize parent, name, options
        super parent, options.merge(:name => name)
        
        recipe @options do        #pass in @options so we can access them in the lingo block
          recipe 'passenger', :version => '2.2.3'
          git_repo "/#{@options.name}", :url => @options.repo, :user => 'www-data', :group => 'www-data'
          
          the_options = @options

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
        puts_title :rails_app, name
      end
      
      def describe_settings
        puts_setting :repo
        puts_setting :env
      end


    end
  end
end

