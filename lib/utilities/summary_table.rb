module Healing
  class SummeryTable < ReportTable
      
    class SummaryRow < ReportRow

      def line column, line
        if column == :item
          @master ? '' : @columns[:item]
        else
          super
        end
      end
      
      def to_s columns
        @columns[:status] = @columns[:fail] ? 'fail' : 'ok'
        super columns
      end
      
    end  
    
    def make_row item, columns
      SummaryRow.new self,item,columns
    end

    def find_insert_pos fingerprint
      r = @rows.reverse.find {|r| r.columns[:fingerprint] == fingerprint }
      pos = @rows.index r
      pos ? pos+1 : -1
    end  
    
    def parse str
      table = str.match(/Healing result:.*?\n\n/m)
      return unless table
      lines = table.to_s.split("\n")
      header = lines[2]
      rows = lines[4..-2]
      fields =  header.split('|').map {|f| f.strip }.reject { |f| f=='' }
      offsets = {}
      fields.each { |f| offsets[f.downcase.to_sym] = header.match(/\s#{f}\s*/).offset(0) }
      rows.each do |row|
        data = {}
        offsets.each { |f,off| data[f] = row[ off[0]..off[1]-1 ].strip }
        process_row data
      end
    end
  
    def process_row data
      existing = @rows.find { |r| r.columns[:fingerprint]==data[:fingerprint] && r.columns[:message]==data[:message] }
      if existing
        existing.bump data[:status]
      else
        master = @rows.find { |r| r.columns[:fingerprint]==data[:fingerprint] && r.master==nil }
        r = make_row nil, data.merge(data[:status].to_sym => 1)
        r.master = master
        @rows.insert find_insert_pos(data[:fingerprint]), r
      end
    end
    
    def failures?
      @rows.any? { |r| r.columns[:fail] }
    end
    
  end
end
