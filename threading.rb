
module Healing
  module Threading

    def puts_progress msg=nil, options={}, &block
      options = { :interval => 1, :dot => '.' }.merge(options)
      print msg if msg
      STDOUT.flush
      t = Thread.new(&block)
      STDOUT.flush
      until t.join(options[:interval])
        if options[:dot]
          print options[:dot] 
          STDOUT.flush
        end
      end 
      puts '' if msg   
    end 
  end
end


class Array
  
    def each_in_thread msg=nil, options={}, &block
      options = { :interval => 1, :dot => '.' }.merge(options)
      threads = []
      print msg if msg
      STDOUT.flush
      each { |item| threads << Thread.new(item,&block) }
      STDOUT.flush
      threads.each do |t|
        until t.join(options[:interval])
          if options[:dot]
            print options[:dot] 
            STDOUT.flush
          end
        end 
      end
      puts '' if msg   
    end
  
end