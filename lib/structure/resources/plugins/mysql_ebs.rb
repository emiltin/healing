module Healing
  module Structure
    class MysqlEbs < Resource
      
      def initialize parent, volume_id, options={}
        super parent, options.merge(:volume_id=>volume_id)
        
        the_parent = self
        recipe do
          volume volume_id

          package 'mysql-client'
          package 'mysql-server'

          service 'mysql' do
            while_stopped do
              execute 'backup /etc/mysql', "mv /etc/mysql /etc/mysql_backup"
              link '/vol/etc/mysql', '/etc/mysql' 
            end
          end
          
        end
      end
      
      def heal
        describe_name
        super
      end
      
      def describe_name
        puts_title :mysql_ebs, ''
      end
      
      def describe_settings
   #     puts_setting :volume_id
      end


    end
  end
end

