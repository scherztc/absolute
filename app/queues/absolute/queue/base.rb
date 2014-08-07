module Absolute
  module Queue
    class Base

      def initialize(redis, coder = Mutex)
        @coder = coder
        @redis = redis
        @redis_name = 'handle'
      end

      def push(item)
        @redis.rpush @redis_name, encode(item)
      end

      def pop
        value = @redis.lpop @redis_name
        decode(value) if value
      end

      # Get the length of the queue
      def length
        @redis.llen @redis_name
      end
      alias :size :length

      # Is the queue empty?
      def empty?
        size == 0
      end

      # Discard all messages in the queue
      def clear
        until empty?
          @redis.lpop @redis_name
        end
      end

      private
        def encode object
          @coder.dump object
        end

        def decode object
          @coder.load object
        end
    end
  end
end

