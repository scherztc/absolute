module Export
  class Handles
    include ActionView::Helpers::TextHelper

    attr_accessor :queue

    def initialize(namespace)
      @namespace = namespace
      @queue = Absolute::Queue::Handle::Base.new(Resque.redis, JSON)
    end

    def export!
      counter = 0
      File.open(file_name, 'w') do |f|
        while object = @queue.pop
          counter += 1
          f.puts command(object)
        end
      end
      puts "Exported #{pluralize(counter, "record")} to #{file_name}"
    end

    private

      def command(object)
        "#{object['verb']} #{@namespace}/#{object['id']}\n" +
        "2 URL 86400 1110 UTF8 #{object['url']}\n\n"
      end

      def file_name
        @file_name ||= "handles-#{Time.now.to_formatted_s(:iso8601).first(19)}.txt"
      end
  end
end
