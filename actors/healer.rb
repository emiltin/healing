
module Healing

  class Healer
    def initialize
      load_ideal
    end
  
    def self.run_locally cmd, options={}
      result  = `#{cmd}`
      puts result unless result=='' || options[:quiet]
      result
    end
  
    def load_ideal
      return if @cloud
      require 'ideal.rb'
      @cloud = Healing::Cloud.root
      raise "No cloud defined in ideal.rb!" unless @cloud
    end
  
  end
  
end
