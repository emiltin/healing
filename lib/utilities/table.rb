module Healing
  class Table
    
    class Column
      attr_reader :sym, :title, :size
      
      def initialize sym,opt={}
        @sym = sym
        @title = opt[:title] || sym.to_s.capitalize
        @size = @title.size
      end
   
      def adjust size
        @size = size ? [@title.size,size].max : @title.size
      end
   end
    
    class Row
      attr_reader :columns
      
      def initialize table,item,columns={}
        @table = table
        @item = item
        @columns = columns
      end
      
      def to_s columns
        (0..height-1).to_a.map do |n|
          str = columns.map {|c|  line(c.sym,n)[0..c.size-1].ljust(c.size) }.join(" #{@table.look[:vertical]} ")
          "#{@table.look[:vertical]} #{str} #{@table.look[:vertical]}"
        end.join("\n")
      end 
      
      def height
        @columns.values.map { |v| v.to_s.split("\n").size }.max
      end

      def width column
        @columns[column].to_s.split("\n").map { |l| l.size }.max
      end
      
      def line column, line
        @columns[column].to_s.split("\n")[line] || ''
      end
      
      def add_line column, str
        @columns[column] = "#{@columns[column]}\n#{str.strip}".strip
      end
      
    end
    
    
    attr_accessor :flags, :look
  
    def initialize *columns
      @look = { :vertical => '|', :horizontal => '-', :corner => '+' }
      @columns = columns
      @rows = []
    end
    
    def clear
      @rows.clear
    end
    
    def adjust
      @columns.each do |c|
        c.adjust @rows.map { |r| r.width(c.sym) }.compact.max { |a,b| a && b ? a<=>b : a }
      end
    end
    
    def make_row item, columns
      Row.new(self,item,columns)
    end
    
    def add_row item, columns
      r = make_row item,columns
      @rows << r
      r
    end
  
    def to_s
      adjust
      if @rows.any?
        [divider,header,divider,rows,divider].join("\n")
      else
        [divider,header,divider].join("\n")
      end      
    end
    
    def divider
      h, c = look[:horizontal], look[:corner]
      s = @columns.map { |col| "#{h*(col.size)}" }.join("#{h}#{c}#{h}")
      "#{c}#{h}#{s}#{h}#{c}"
    end
    
    def header
      v = look[:vertical]
      s = @columns.map { |c| "#{c.title.to_s[0..c.size-1].ljust(c.size)}" }.join(" #{v} ")
      "#{v} #{s} #{v}"
    end

    def rows
      @rows.map { |r| r.to_s @columns }.join("\n")
    end
  
  end

end
