module Healing
  module Structure
    class Failer < Resource

      def diagnose
        return "Will fail randomly with a random message" 
      end
      
      def heal
  #      if rand(100)>50
  #      else
          raise rand(5).to_s*10
  #      end
      end

      def describe_name
        puts_title :failer, ''
      end

    end
  end
end

          
