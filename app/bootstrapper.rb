module Healing
  module App
    class Bootstrapper

      def initialize instances
        @instances = instances
      end

      def bootstrap
        #after launching an instance, ruby might not be installed, so we need to manually bootstrap a minimal environment
        installer = "apt-get"   #should be determined from the os launched. how?
        @instances.each_in_thread "Bootstrapping" do |i|
          i.command "mkdir /healing"
          i.command "echo '#{i.cloud_uuid}' > #{CLOUD_UUID_PATH}"
          i.command "#{installer} update"
          #i.command "#{installer} upgrade"
          i.command "#{installer} install ruby libreadline-ruby1.8 libruby1.8 ruby1.8-dev ruby1.8 rubygems -y"    #dev version is needed for building some gems, like passenger
          i.command "echo 'export PATH=$PATH:/var/lib/gems/1.8/bin' >> /etc/profile"
          i.execute
          
          #at this point we could upload healing and use it to install packages etc.
          #      i.command "gem source --add http://gems.github.com"
          #what else is needed?
        end
      end

    end
  end
end
