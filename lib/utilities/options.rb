module Healing
  class Options
    
    def initialize options={}
      @options = options
    end
    
    def method_missing(sym, *args, &block)
      if match = sym.to_s.match(/(.+)\?/)
        @options[match[1].to_sym]!=nil &&
        (@options[match[1].to_sym]!=false && @options[match[1].to_sym]!= :false && @options[match[1].to_sym]!=0 )
      elsif match = sym.to_s.match(/(.+)=/)
        @options[match[1].to_sym] = args[0]
        args[0]
      else
        @options[sym]
      end
    end
    
  end
end