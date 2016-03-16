module EmailEvents::Adapters
  module Abstract
    class Initializer
      def self.load_adapter?
        raise "Not implemented"
      end

      def self.initialize
        raise "Not implemented"
      end
    end
  end
end
