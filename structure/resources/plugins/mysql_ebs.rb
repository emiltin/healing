module Healing
  module Structure
    class MysqlEbs < Resource

      def initialize parent, volume_id, options={}
        super parent, options.merge(:volume_id=>volume_id)
        
        recipe do
          volume volume_id if volume_id

          package 'mysql-client'
          package 'mysql-server'

          service 'mysql' => :off

          execute 'kill mysqld_safe', "killall mysqld_safe"
          execute 'adjust mysql binary logs', "test -f /vol/log/mysql/mysql-bin.index && perl -pi -e 's%/var/log/%/vol/log/%' /vol/log/mysql/mysql-bin.index"

          file '/etc/mysql/conf.d/mysql-ec2.cnf', :mode => 644, :content => <<-EOF
[mysqld]
innodb_file_per_table
datadir          = /vol/lib/mysql
log_bin          = /vol/log/mysql/mysql-bin.log
max_binlog_size  = 1000M
#log_slow_queries = /vol/log/mysql/mysql-slow.log
#long_query_time  = 10
EOF

          service 'mysql' => :on
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

