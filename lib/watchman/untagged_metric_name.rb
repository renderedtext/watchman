class Watchman
    class UntaggedMetricName
      def self.construct(base_name, prefix)
        new(base_name, prefix).construct
      end
  
      def initialize(base_name, prefix = nil)
        @base_name = base_name
        @prefix = prefix
      end
  
      def construct
        full_name = []
  
        full_name << @prefix       if @prefix
        full_name << @base_name
  
        full_name.join(".")
      end
    end
  end
  