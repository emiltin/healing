module Healing
  module Structure
    class Instance < Cloud


      def heal
        log "instance: #{@name}"
        @children.each { |item| item.heal }
      end

    end
  end
end

