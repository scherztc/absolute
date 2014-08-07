module Absolute
  module Queue
    module Handle
      class Base < Queue::Base
        def push(item)
          super(item.merge(verb: verb))
        end

        def verb
          raise NotImplementedError, "Implement on a subclass"
        end
      end
    end
  end
end

