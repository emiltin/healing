
module Healing
  class Provider
    
    def self.build name
      case name.to_s.downcase
      when "ec2"
        Healing::EC2.new
      else
        raise "Unknown provider '#{name}'."
      end
    end
    
    def initialize options={}
      @options = options
    end
  
    def run
      #@ec2.run_instances :image_id => "ami-bf5eb9d6", :key_name => 'testpair', :zone => 'us-east-1a'
    end
  
    def terminate
    end
  
    def describe
    end
  
  end
  
end