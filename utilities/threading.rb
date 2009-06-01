
module Healing
  module Threading

    def puts_progress msg=nil, options={}, &block
      options = { :interval => 1, :dot => '.', :just => 30 }.merge(options)
      print msg.ljust(options[:just]) if msg
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

    def each_in_thread msg=nil, options={}, &block
      if msg
        puts_progress(msg, options) { each_in_thread_silently options, &block }
      else
        each_in_thread_silently options, &block
      end
    end
    
    def each_in_thread_silently options, &block
      options = { :interval => 1 }.merge(options)
      threads = map { |i| Thread.new(i,&block) }
      threads.each { |t| {} until t.join(options[:interval]) }
    end
    
  end
end

class Array
  include Healing::Threading  
end