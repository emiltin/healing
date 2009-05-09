class Heal
  class Cloud
  
    def initialize name
      @name = name
      @resources = []
      healer.current_cloud.add self if healer.current_cloud
    end

    def add resource
      @resources << resource
    end
  
    def resources
      @resources
    end
  
    def heal
      puts "~~~~ cloud #{@name} ~~~~"
      @resources.each { |item| item.heal }
    end

  end
end
