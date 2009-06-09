module Healing
  module Structure
    class RailsApp < Resource

      def initialize parent, name, options
        super parent, options.merge(:name => name)
        
        p 'xxxxxxxx'
        p @parent
        p parent_cloud
        the_name = name
        the_repo = repo
        before do
          recipe 'passenger'
          git_repo "/#{the_name}", :url => the_repo, :user => 'www-data', :group => 'www-data'

          #remove default virtual host
          file '/etc/apache2/sites-enabled/000-default', :remove => true

          #add virtual host
          file "/etc/apache2/sites-enabled/#{the_name}", :content => <<-EOF
<Directory "/#{the_name}">
 Options FollowSymLinks
 AllowOverride None
 Order allow,deny
 Allow from all
</Directory>

<VirtualHost *:80>
 ServerName localhost
 DocumentRoot /#{the_name}/public
 RailsEnv development
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

