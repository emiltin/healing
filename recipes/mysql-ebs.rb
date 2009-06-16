
#mysql on amazon an EBS volume.
#the ebs volume is expected to be mounted at /vol
#the mysql folders are initially copied from /var/...

package 'mysql-client'
package 'mysql-server'
rubygem 'mysql'




service 'mysql' => :off

execute 'kill mysqld_safe', "killall mysqld_safe"
execute 'adjust mysql binary logs', "test -f /vol/log/mysql/mysql-bin.index && perl -pi -e 's%/var/log/%/vol/log/%' /vol/log/mysql/mysql-bin.index"

file '/etc/mysql/conf.d/mysql-ec2.cnf', :mode => 644, :content => 
"[mysqld]
innodb_file_per_table
datadir          = /vol/lib/mysql
log_bin          = /vol/log/mysql/mysql-bin.log
max_binlog_size  = 1000M
#log_slow_queries = /vol/log/mysql/mysql-slow.log
#long_query_time  = 10"

service 'mysql' => :on
