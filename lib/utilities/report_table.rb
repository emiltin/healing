module Healing
  class ReportTable < Table
      
    class ReportRow < Table::Row
      attr_accessor :master

      def bump column
        @columns[column.to_sym] ||= 0
        @columns[column.to_sym] += 1
      end

    end
    
    def to_s
      "Healing result:\n" + super + "\n\n"
    end
        
    def make_row item, columns
      ReportRow.new self,item,columns
    end
   
  end
end
