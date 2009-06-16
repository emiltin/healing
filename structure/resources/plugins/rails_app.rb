module Healing
  module Structure
    class RailsApp < Resource

      def initialize parent, name, options
        super parent, options.merge(:name => name)
        
        recipe @options do        #pass in @options so we can access them in the lingo block
          recipe 'passenger'
          git_repo "/#{@options.name}", :url => @options.repo, :user => 'www-data', :group => 'www-data'

          #remove default virtual host
          file '/etc/apache2/sites-enabled/000-default', :remove => true

          #add virtual host
          file "/etc/apache2/sites-enabled/#{@options.name}", :content => <<-EOF
<Directory "/#{@options.name}">
 Options FollowSymLinks
 AllowOverride None
 Order allow,deny
 Allow from all
</Directory>

<VirtualHost *:80>
 ServerName localhost
 DocumentRoot /#{@options.name}/public
 RailsEnv #{@options.environment}
</VirtualHost>
          EOF

          service 'apache2' => :restart
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

