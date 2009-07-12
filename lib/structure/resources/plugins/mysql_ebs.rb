module Healing
  module Structure
    class MysqlEbs < Resource
      
      def initialize parent, volume_id, options={}
        super parent, options.merge(:volume_id=>volume_id)
        
        the_parent = self
        lingo do
          volume volume_id

          package 'mysql-client'
          package 'mysql-server'
          
          service 'mysql' do
            while_stopped do
              execute 'backup original folder', "mv /etc/mysql /etc/mysql_backup"
              link '/etc/mysql', '/vol/etc/mysql'
            end
          end
          
        end
      end
      
      def heal
        describe_name
        super
      end
      
      def type
        "plugin"
      end
      
      def name
        "mysql on ebs"
      end
      
      def ref
        "mysql+ebs plugin"
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

