module Healing
  class Reporter < Table
       
    class ReporterRow < Table::Row
      def initialize table,item,columns={}
        super table,item,columns
        @messages = {}
        add_msg columns[:message]
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

      def add_msg msg
        if msg && msg!=''
          @messages[msg] = @messages[msg] ? @messages[msg]+1 : 1 
        end
      end
      
      def build_messages_column
        @columns[:message] = @messages.map { |k,v| "#{v}x".ljust(4) + extract(k) }.join("\n") if @messages.any?
      end
    end
    
    
    def to_s
      @rows.each { |r| r.build_messages_column }
      "Healing result:\n" + super + "\n\n"
    end
    
    def make_row item, columns
      ReporterRow.new(self,item,columns)
    end
    
    def bump_row row,status,message
      row.columns[status] = row.columns[status] ? row.columns[status]+1 : 1
      row.add_msg message
    end

    def parse str
      summary = str.match(/Healing result:.*?\n\n/m)
      return unless summary
      summary = summary.to_s.split("\n")[4..-2].join("\n")
      summary.scan(/\|.*\|/).each do |line|
        match = /\|(.*)\|(.*)\|(.*)\|(.*)\|/.match line
        if match
          status = match[1].strip
          item = match[2].strip
          message = match[3].strip
          fingerprint = match[4].strip
          
          existing = @rows.find { |r| r.columns[:fingerprint]==fingerprint }
          if existing
            bump_row existing, status.to_sym, message
          else
            add_row nil, {status.to_sym => 1, :fingerprint => fingerprint, :item => item, :message => message}
          end
        end
      end
    end
  
  end
end
