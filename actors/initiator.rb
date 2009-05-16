require 'rubygems'
require 'net/ssh'
require 'EC2'
require 'healing'
require 'providers/provider.rb'
require 'providers/ec2.rb'

module Healing
  class Initiator < Healer
  
    def load_ideal
      super
    end
  
    def describe
      @cloud.describe :recurse => true
    end
  
    def start
      @cloud.start
    end

    def upload
      @cloud.install
    end

    def terminate
      @cloud.terminate
    end
  
    def heal
      @cloud.heal_remote
    end

    def scan
      @cloud.map.show
    end
    
  end
end
