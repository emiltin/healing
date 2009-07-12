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
      existing = @rows.find { |r| r.columns[:fingerprint]==data[:fingerprint] && r.columns[:message]==data[:message] && r.columns[data[:status]] }
      if existing
        existing.bump data[:status]
      else
        master = @rows.find { |r| r.columns[:fingerprint]==data[:fingerprint] && r.master==nil }
        r = make_row nil, data.merge(data[:status].to_sym => 1)
        r.master = master
        @rows.insert find_insert_pos(data[:fingerprint]), r
      end
    end
    
  end
end
