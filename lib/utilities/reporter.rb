module Healing
  class Reporter < Table
      
    class Report < Table::Row
      attr_accessor :master
      
      def initialize table,item,columns={}
        super table,item,columns
      end

      def line column, line
    #    return super(column, line)
        if column == :item && @columns[:status]==nil
          @master ? '' : @columns[:item]
        else
          super
        end
      end
      
      def extract str, len=60
        max = (len-4)*0.5
        if str.size<=len
          s = str
        else
          s = str.strip
          first = s.split("\n").first
          last = s.split("\n").last
          s = "#{first[0..max]}....#{last[-max..-1]}"
        end
        s.gsub(/\n/,'\\')
      end

      def add_report status, msg
        if msg && msg!=''
          @reports[msg] = @messages[msg] ? @messages[msg]+1 : 1 
        end
      end

      def bump column
        @columns[column.to_sym] ||= 0
        @columns[column.to_sym] += 1
      end

    end
    
    
    def to_s
      "Healing result:\n" + super + "\n\n"
    end
    
    def make_row item, columns
      Report.new self,item,columns
    end
    
    def find_insert_pos fingerprint
      r = @rows.reverse.find {|r| r.columns[:fingerprint] == fingerprint }
      pos = @rows.index r
      pos ? pos+1 : -1
    end
  
    
    def parse str
      summary = str.match(/Healing result:.*?\n\n/m)
      return unless summary
      summary = summary.to_s.split("\n")[4..-2].join("\n")
      summary.scan(/\|.*\|/).each do |line|
        match = /\|(.*)\|(.*)\|(.*)\|(.*)\|/.match line
        if match
          status = match[1].strip.to_sym
          item = match[2].strip
          message = match[3].strip
          fingerprint = match[4].strip
          
          existing = @rows.find { |r| r.columns[:fingerprint]==fingerprint && r.columns[:message]==message && r.columns[status] }
          if existing
            existing.bump status
          else
            master = @rows.find { |r| r.columns[:fingerprint]==fingerprint && r.master==nil }
            
            r = make_row nil, {status => 1, :fingerprint => fingerprint, :item => item, :message => message}
            r.master = master
            
            @rows.insert find_insert_pos(fingerprint), r
          end
        end
      end
    end
  
    
  end
end
