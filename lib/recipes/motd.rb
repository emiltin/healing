#set the message of the day (ssh login message)

file '/etc/motd', :content => @options.message
